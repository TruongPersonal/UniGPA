import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/data/providers/grade_config_provider.dart';

import '../../../data/models/academic_semester.dart';

Future<void> showAddSubjectSheet(
  BuildContext context, {
  int? editIndex,
  Subject? editSubject,
}) {
  final gpaProvider = context.read<GPAProvider>();
  final semProvider = context.read<SemesterProvider>();
  final gradeProvider = context.read<GradeConfigProvider>();

  return AppBottomSheet.show(
    context: context,
    builder: (ctx) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gpaProvider),
        ChangeNotifierProvider.value(value: semProvider),
        ChangeNotifierProvider.value(value: gradeProvider),
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
  late final TextEditingController _processWeightCtrl;
  late final TextEditingController _processPointCtrl;
  late final TextEditingController _examPointCtrl;
  
  AcademicSemester? _selectedSemester;
  bool _isViewingMode = false;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.editSubject;
    _isViewingMode = widget.isEditing && s?.finalPoint10 == null && s?.processPoint != null && s?.processWeight != null;
    
    _nameCtrl = TextEditingController(text: s?.name ?? '')..addListener(_onInputChanged);
    _creditsCtrl = TextEditingController(text: s != null ? '${s.credits}' : '')..addListener(_onInputChanged);
        
    _processWeightCtrl = TextEditingController(text: s?.processWeight != null ? (s!.processWeight! * 100).toStringAsFixed(0) : '')..addListener(_onInputChanged);
    _processPointCtrl = TextEditingController(text: s?.processPoint != null ? _fmtNum(s!.processPoint!) : '')..addListener(_onInputChanged);
    _examPointCtrl = TextEditingController(text: s?.examPoint != null ? _fmtNum(s!.examPoint!) : '')..addListener(_onInputChanged);
        
    _selectedSemester = s?.semester;
  }

  void _onInputChanged() => setState(() {});

  bool get _isValid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    final credits = int.tryParse(_creditsCtrl.text);
    if (credits == null || credits <= 0) return false;
    if (_selectedSemester == null) return false;
    
    final pWeightText = _processWeightCtrl.text;
    final pPointText = _processPointCtrl.text.replaceAll(',', '.');
    final ePointText = _examPointCtrl.text.replaceAll(',', '.');
    
    if (pWeightText.isNotEmpty) {
      final w = double.tryParse(pWeightText);
      if (w == null || w < 0 || w > 100) return false;
    }
    if (pPointText.isNotEmpty) {
      final p = double.tryParse(pPointText);
      if (p == null || p < 0 || p > 10) return false;
    }
    if (ePointText.isNotEmpty) {
      final e = double.tryParse(ePointText);
      if (e == null || e < 0 || e > 10) return false;
    }
    
    return true;
  }

  String _fmtNum(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _creditsCtrl.dispose();
    _processWeightCtrl.dispose();
    _processPointCtrl.dispose();
    _examPointCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isViewingMode) return _buildViewMode(context);
    return _buildEditMode(context);
  }

  Widget _buildViewMode(BuildContext context) {
    final colors = context.colors;
    final s = widget.editSubject!;

    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi tiết môn học',
                style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                onPressed: () => setState(() => _isViewingMode = false),
              ),
            ],
          ),
          SizedBox(height: 16,),
          _buildTargetScoresTable(context, s),
        ],
      )
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final colors = context.colors;
    final semesters = context.watch<SemesterProvider>().semesters;

    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing ? 'Sửa môn học' : 'Thêm môn học',
            style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                 flex: 2,
                 child: AppTextField(controller: _nameCtrl, label: 'Tên môn học', hint: 'vd: Giải tích 1'),
              ),
              const SizedBox(width: 12),
              Expanded(
                 flex: 1,
                 child: AppTextField(
                   controller: _creditsCtrl,
                   label: 'Tín chỉ',
                   hint: 'vd: 3',
                   keyboardType: TextInputType.number,
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                 ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                 child: AppTextField(
                   controller: _processWeightCtrl,
                   label: 'Hệ số QTHT',
                   hint: 'vd: 30',
                   keyboardType: TextInputType.number,
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                 ),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: AppTextField(
                   controller: _processPointCtrl,
                   label: 'QTHT',
                   hint: 'vd: 8.5',
                   enabled: _processWeightCtrl.text != '0',
                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                   inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*'))],
                 ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _examPointCtrl,
            label: 'KTHPT',
            hint: 'vd: 9.0',
            enabled: _processWeightCtrl.text != '100',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*'))],
          ),
          const SizedBox(height: 16),
          Text('Học kỳ', style: AppTextStyles.labelLarge.copyWith(color: colors.textPrimary)),
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
                          child: Text('Chọn học kỳ', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
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
                                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
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
              decoration: BoxDecoration(border: Border.all(color: colors.divider), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSemester != null ? 'HK${_selectedSemester!.semester} · ${_selectedSemester!.year.yearDisplay}' : 'Chọn học kỳ...',
                    style: AppTextStyles.bodyLarge.copyWith(color: _selectedSemester != null ? colors.textPrimary : colors.textHint),
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

  Widget _buildTargetScoresTable(BuildContext context, Subject s) {
    if (s.processWeight == null) return const SizedBox();
    if (s.processWeight! > 0 && s.processPoint == null) return const SizedBox();
    
    final activeGrades = context.watch<GradeConfigProvider>().grades.where((g) => g.isActive).toList();
    if (activeGrades.isEmpty) return const SizedBox();

    final pWeight = s.processWeight!;
    final pPoint = s.processPoint ?? 0.0;

    final wEnd = 1 - pWeight;
    if (wEnd <= 0) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Loại', style: AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary))),
                      Expanded(flex: 3, child: Text('Tổng kết', style: AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary))),
                      Expanded(flex: 3, child: Text('Cần đạt', textAlign: TextAlign.right, style: AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary))),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.colors.divider),
                ...activeGrades.map((grade) {
                  final targetScore = grade.startPoint10!;
                  double needed = (targetScore - pPoint * pWeight) / wEnd;
                  String text = '';
                  Color textColor = context.colors.textPrimary;
                  
                  if (needed <= 0) {
                    text = 'O';
                    textColor = AppColors.success;
                  } else if (needed > 10) {
                    text = 'X';
                    textColor = AppColors.error;
                  } else {
                    text = needed.toStringAsFixed(2);
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.letterColor(grade.letter).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  grade.letter,
                                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.letterColor(grade.letter)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3, 
                          child: Text('>= ${grade.startPoint10}', style: AppTextStyles.bodyLarge.copyWith(color: context.colors.textPrimary)),
                        ),
                        Expanded(
                          flex: 3, 
                          child: Text(text, textAlign: TextAlign.right, style: AppTextStyles.headingSmall.copyWith(color: textColor)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      )
    );
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    final processWeight = double.tryParse(_processWeightCtrl.text);
    final processPoint = double.tryParse(_processPointCtrl.text.replaceAll(',', '.'));
    final examPoint = double.tryParse(_examPointCtrl.text.replaceAll(',', '.'));

    final subject = Subject(
      name: _nameCtrl.text.trim(),
      credits: int.parse(_creditsCtrl.text),
      semester: _selectedSemester!,
      processPoint: processPoint,
      processWeight: processWeight != null ? processWeight / 100 : null,
      examPoint: examPoint,
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
