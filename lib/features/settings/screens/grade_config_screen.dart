import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/providers/grade_config_provider.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/core/widgets/app_logo_title.dart';

class GradeConfigScreen extends StatelessWidget {
  const GradeConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
        child: Consumer<GradeConfigProvider>(
          builder: (context, provider, _) {
            final grades = provider.grades;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Điểm',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Khoảng điểm 10',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          'Điểm 4',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 52,
                        child: Text(
                          'Dùng',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: grades.asMap().entries.map((entry) {
                      final index = entry.key;
                      final grade = entry.value;
                      final isLast = index == grades.length - 1;
                      return _GradeConfigTile(
                        grade: grade,
                        showDivider: !isLast,
                        onEdit: () =>
                            _showEditDialog(context, provider, index, grade),
                        onToggle: () async {
                          await provider.toggleActive(index);
                          if (context.mounted) {
                            context.read<GPAProvider>().reload();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    GradeConfigProvider provider,
    int index,
    Grade grade,
  ) {
    AppBottomSheet.show(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: _EditGradeSheet(index: index, grade: grade),
      ),
    );
  }
}

class _GradeConfigTile extends StatelessWidget {
  const _GradeConfigTile({
    required this.grade,
    required this.showDivider,
    required this.onEdit,
    required this.onToggle,
  });

  final Grade grade;
  final bool showDivider;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = grade.isActive;

    final gradeColor = AppColors.letterColor(grade.letter);

    return Column(
      children: [
        InkWell(
          onTap: isActive ? onEdit : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? gradeColor.withValues(alpha: 0.15)
                        : colors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      grade.letter,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isActive ? gradeColor : colors.textHint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    grade.startPoint10 != null && grade.endPoint10 != null
                        ? '${_fmt(grade.startPoint10!)} – ${_fmt(grade.endPoint10!)}'
                        : '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive ? colors.textPrimary : colors.textHint,
                    ),
                  ),
                ),

                SizedBox(
                  width: 64,
                  child: Text(
                    grade.point4 != null ? _fmt(grade.point4!) : '—',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isActive ? colors.textPrimary : colors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Switch.adaptive(
                  value: isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: colors.primaryLight,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 16, endIndent: 16, color: colors.divider),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _EditGradeSheet extends StatefulWidget {
  const _EditGradeSheet({required this.index, required this.grade});
  final int index;
  final Grade grade;

  @override
  State<_EditGradeSheet> createState() => _EditGradeSheetState();
}

class _EditGradeSheetState extends State<_EditGradeSheet> {
  late final TextEditingController _point4Ctrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final g = widget.grade;
    _point4Ctrl = TextEditingController(
      text: g.point4?.toStringAsFixed(1) ?? '',
    )..addListener(_onInputChanged);
    _startCtrl = TextEditingController(
      text: g.startPoint10?.toStringAsFixed(1) ?? '',
    )..addListener(_onInputChanged);
    _endCtrl = TextEditingController(
      text: g.endPoint10?.toStringAsFixed(1) ?? '',
    )..addListener(_onInputChanged);
  }

  void _onInputChanged() => setState(() {});

  bool get _isValid {
    final point4 = double.tryParse(_point4Ctrl.text.replaceAll(',', '.'));
    if (point4 == null || point4 < 0 || point4 > 4.0) return false;

    final start = double.tryParse(_startCtrl.text.replaceAll(',', '.'));
    if (start == null || start < 0 || start > 10.0) return false;

    final end = double.tryParse(_endCtrl.text.replaceAll(',', '.'));
    if (end == null || end < 0 || end > 10.0) return false;

    if (start > end) return false;

    return true;
  }

  @override
  void dispose() {
    _point4Ctrl.removeListener(_onInputChanged);
    _startCtrl.removeListener(_onInputChanged);
    _endCtrl.removeListener(_onInputChanged);
    _point4Ctrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
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
          Text(
            'Cấu hình điểm ${widget.grade.letter}',
            style: AppTextStyles.headingMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _point4Ctrl,
            label: 'Điểm (Thang 4)',
            hint: 'vd: 4.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
            ],
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _startCtrl,
                  label: 'Từ điểm (Thang 10)',
                  hint: 'vd: 8.5',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                  ],
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _endCtrl,
                  label: 'Đến điểm (Thang 10)',
                  hint: 'vd: 10.0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                  ],
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: _isValid && !_isLoading ? _submit : null,
            isLoading: _isLoading,
            label: 'Lưu',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    final point4 = double.tryParse(_point4Ctrl.text.replaceAll(',', '.'))!;
    final start = double.tryParse(_startCtrl.text.replaceAll(',', '.'))!;
    final end = double.tryParse(_endCtrl.text.replaceAll(',', '.'))!;

    final provider = context.read<GradeConfigProvider>();
    await provider.updateGrade(
      widget.index,
      Grade(
        letter: widget.grade.letter,
        point4: point4,
        startPoint10: start,
        endPoint10: end,
        isActive: widget.grade.isActive,
      ),
    );

    if (mounted) {
      context.read<GPAProvider>().reload();
      Navigator.pop(context);
    }
  }
}
