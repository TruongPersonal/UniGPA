import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';

Future<void> showAddSubjectSheet(
  BuildContext context, {
  int? editIndex,
  Subject? editSubject,
}) {
  final gpaProvider = context.read<GPAProvider>();
  final semProvider = context.read<SemesterProvider>();

  return AppBottomSheet.show(
    context: context,
    builder: (ctx) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gpaProvider),
        ChangeNotifierProvider.value(value: semProvider),
      ],
      child: _AddSubjectSheet(
        editIndex: editIndex,
        editSubject: editSubject,
      ),
    ),
  );
}

class _AddSubjectSheet extends StatefulWidget {
  const _AddSubjectSheet({this.editIndex, this.editSubject});
  final int? editIndex;
  final Subject? editSubject;

  bool get isEditing => editIndex != null && editSubject != null;

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _creditsCtrl;
  late final TextEditingController _pointCtrl;
  AcademicSemester? _selectedSemester;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.editSubject;
    _nameCtrl = TextEditingController(text: s?.name ?? '')..addListener(_onInputChanged);
    _creditsCtrl = TextEditingController(
        text: s != null ? '${s.credits}' : '')..addListener(_onInputChanged);
    _pointCtrl = TextEditingController(
        text: s != null ? _fmtNum(s.point10) : '')..addListener(_onInputChanged);
    _selectedSemester = s?.semester;
  }

  void _onInputChanged() => setState(() {});

  bool get _isValid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    final credits = int.tryParse(_creditsCtrl.text);
    if (credits == null || credits <= 0) return false;
    final point = double.tryParse(_pointCtrl.text.replaceAll(',', '.'));
    if (point == null || point < 0 || point > 10) return false;
    if (_selectedSemester == null) return false;
    return true;
  }

  String _fmtNum(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _nameCtrl.removeListener(_onInputChanged);
    _creditsCtrl.removeListener(_onInputChanged);
    _pointCtrl.removeListener(_onInputChanged);
    _nameCtrl.dispose();
    _creditsCtrl.dispose();
    _pointCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semesters = context.watch<SemesterProvider>().semesters;

    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing ? 'Sửa môn học' : 'Thêm môn học',
            style: AppTextStyles.headingMedium
                .copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _nameCtrl,
            label: 'Tên môn học',
            hint: 'vd: Giải tích 1',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     AppTextField(
                       controller: _creditsCtrl,
                       label: 'Số tín chỉ',
                       hint: 'vd: 3',
                       keyboardType: TextInputType.number,
                       inputFormatters: [
                         FilteringTextInputFormatter.digitsOnly
                       ],
                     ),
                   ],
                 ),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     AppTextField(
                       controller: _pointCtrl,
                       label: 'Điểm (thang 10)',
                       hint: 'vd: 8.5',
                       keyboardType:
                           const TextInputType.numberWithOptions(
                               decimal: true),
                       inputFormatters: [
                         FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                       ],
                       autocorrect: false,
                     ),
                   ],
                 ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Học kỳ',
            style: AppTextStyles.labelLarge.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final selected = await showDialog<AcademicSemester>(
                  context: context,
                  builder: (ctx) => Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: colors.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: Text('Chọn học kỳ',
                                style: AppTextStyles.headingSmall
                                    .copyWith(color: colors.textPrimary)),
                          ),
                          Divider(height: 1, color: colors.divider),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: semesters.map((sem) {
                                  final isSelected = _selectedSemester == sem;
                                  return ListTile(
                                    title: Text(
                                      'HK${sem.semester} · ${sem.year.yearDisplay}',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: isSelected ? AppColors.primary : colors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                        : null,
                                    onTap: () => Navigator.pop(ctx, sem),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _selectedSemester = selected;
                    _onInputChanged();
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedSemester != null
                          ? 'HK${_selectedSemester!.semester} · ${_selectedSemester!.year.yearDisplay}'
                          : 'Chọn học kỳ...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _selectedSemester != null
                            ? colors.textPrimary
                            : colors.textHint,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down_rounded, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),

          AppButton(
            onPressed: _isValid && !_isLoading ? _submit : null,
            isLoading: _isLoading,
            label: 'Lưu',
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    final rawPoint10 = double.parse(_pointCtrl.text.replaceAll(',', '.'));
    final roundedPoint10 = double.parse(rawPoint10.toStringAsFixed(1));

    final subject = Subject(
      name: _nameCtrl.text.trim(),
      credits: int.parse(_creditsCtrl.text),
      point10: roundedPoint10,
      semester: _selectedSemester!,
    );

    final provider = context.read<GPAProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final isEdit = widget.isEditing;
    final editIndex = widget.editIndex;

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);

    if (isEdit) {
      await provider.updateSubject(editIndex!, subject);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật môn học thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      await provider.addSubject(subject);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Đã thêm môn học thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}




