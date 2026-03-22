import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/widgets/empty_state.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/year.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/data/services/storage_service.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/core/widgets/app_logo_title.dart';

class SemesterManagementScreen extends StatelessWidget {
  const SemesterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: 'Trở về',
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const AppLogoTitle(),
      ),
      body: SafeArea(
        child: Consumer<SemesterProvider>(
          builder: (context, provider, _) {
          if (provider.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'Chưa có học vụ nào',
            );
          }

          final years = provider.distinctYears;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: years.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final year = years[i];
              return _YearSection(
                year: year,
                semesters: provider.semestersOfYear(year),
                onDelete: (sem) => _onDelete(context, provider, sem),
              );
            },
          );
        },
      )),
      floatingActionButton: Consumer<SemesterProvider>(
        builder: (context, provider, _) => FloatingActionButton(
          onPressed: () => _showAddDialog(context, provider),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Future<bool> _onDelete(
    BuildContext context,
    SemesterProvider provider,
    AcademicSemester semester,
  ) async {
    final success = await provider.deleteSemester(semester);
    if (!context.mounted) return success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xoá học kỳ thành công!' : 'Học kỳ đang có môn học!',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
    return success;
  }

  void _showAddDialog(BuildContext context, SemesterProvider provider) {
    AppBottomSheet.show(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _AddSemesterSheet(),
      ),
    );
  }
}

class _YearSection extends StatelessWidget {
  const _YearSection({
    required this.year,
    required this.semesters,
    required this.onDelete,
  });

  final Year year;
  final List<AcademicSemester> semesters;
  final Future<bool> Function(AcademicSemester semester) onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Năm học ${year.yearDisplay}',
          style: AppTextStyles.labelMedium
              .copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: semesters.asMap().entries.map((entry) {
                final index = entry.key;
                final semester = entry.value;
                final isLast = index == semesters.length - 1;
                return _SemesterTile(
                  semester: semester,
                  showDivider: !isLast,
                  onDelete: () async {
                    return await onDelete(semester);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SemesterTile extends StatelessWidget {
  const _SemesterTile({
    required this.semester,
    required this.showDivider,
    required this.onDelete,
  });

  final AcademicSemester semester;
  final bool showDivider;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dismissible(
      key: ValueKey('sem_${semester.semester}_${semester.year.start}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await _confirmDelete(context);
        if (confirm != true) return false;

        if (StorageService.semesterHasSubjects(semester)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Học kỳ đang có môn học!'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error.withValues(alpha: 0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_rounded, color: AppColors.error),
            const SizedBox(height: 4),
            Text(
              'Xoá',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      child: AppListTile(
        title: 'Học kỳ ${semester.semester}',
        subtitle: semester.year.yearDisplay,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${semester.semester}',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        showDivider: showDivider,
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá học kỳ?'),
        content: Text(
            'Xoá HK${semester.semester} · ${semester.year.yearDisplay}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

class _AddSemesterSheet extends StatefulWidget {
  const _AddSemesterSheet();

  @override
  State<_AddSemesterSheet> createState() => _AddSemesterSheetState();
}

class _AddSemesterSheetState extends State<_AddSemesterSheet> {
  late final TextEditingController _yearCtrl;
  int? _startYear;
  int _semesterNumber = 1;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _yearCtrl = TextEditingController();
    _yearCtrl.addListener(() {
      final y = int.tryParse(_yearCtrl.text);
      setState(() => _startYear = y);
    });
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thêm học vụ',
                style: AppTextStyles.headingMedium
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 24),

            Text('Năm học',
                style: AppTextStyles.labelLarge
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: AppTextField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 4,
                    autocorrect: false,
                    hint: 'vd: 2025',
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            Text('Học kỳ',
                style: AppTextStyles.labelLarge
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [1, 2, 3].map((n) {
                final selected = _semesterNumber == n;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$n'),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _semesterNumber = n),
                    selectedColor: colors.primaryLight,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : colors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: selected ? AppColors.primary : colors.divider,
                      ),
                    ),
                    backgroundColor: colors.surface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            AppButton(
              onPressed: _startYear == null ? null : _submit,
              isLoading: _isLoading,
              label: 'Lưu',
            ),
            const SizedBox(height: 8),
          ],
        ),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<SemesterProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
    
    final exists = provider.semesters.any((s) => 
      s.year.start == _startYear && s.semester == _semesterNumber
    );
    
    if (exists) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Học kỳ này đã tồn tại!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await provider.addSemester(
      year: Year(_startYear!, _startYear! + 1),
      semesterNumber: _semesterNumber,
    );
    
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Đã thêm học kỳ thành công!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
