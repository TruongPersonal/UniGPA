import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_bottom_sheet.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';
import 'package:unigpa/domain/usecases/gpa/calculate_target_grades.dart';
import 'package:unigpa/features/grades/providers/grades_provider.dart';


class PlanGradesSheet extends StatefulWidget {
  const PlanGradesSheet({
    super.key,
    required this.targetGpa,
    required this.currentGpa,
    required this.currentCredits,
    required this.remainingCredits,
  });

  final double targetGpa;
  final double currentGpa;
  final int currentCredits;
  final int remainingCredits;

  @override
  State<PlanGradesSheet> createState() => _PlanGradesSheetState();
}

class _PlanGradesSheetState extends State<PlanGradesSheet> {
  final List<_SubjectInputRow> _rows = [
    _SubjectInputRow(TextEditingController(), TextEditingController()),
  ];
  
  List<GradeAssignment>? _result;
  bool _calculated = false;

  void _addRow() {
    setState(() {
      _rows.add(_SubjectInputRow(TextEditingController(), TextEditingController()));
      _calculated = false;
      _result = null;
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows[index].countCtrl.dispose();
        _rows[index].creditCtrl.dispose();
        _rows.removeAt(index);
        _calculated = false;
        _result = null;
      });
    }
  }

  int get _currentInputCredits {
    int total = 0;
    for (var row in _rows) {
      final count = int.tryParse(row.countCtrl.text) ?? 0;
      final credit = int.tryParse(row.creditCtrl.text) ?? 0;
      total += count * credit;
    }
    return total;
  }

  bool get _isValid => _currentInputCredits == widget.remainingCredits;

  void _onInputChanged() {
    setState(() {
      _calculated = false;
      _result = null;
    });
  }

  void _calculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    
    List<SubjectRequirement> reqs = [];
    for (var row in _rows) {
      final count = int.tryParse(row.countCtrl.text) ?? 0;
      final credit = int.tryParse(row.creditCtrl.text) ?? 0;
      if (count > 0 && credit > 0) {
        reqs.add(SubjectRequirement(count, credit));
      }
    }

    final activeGrades = context.read<GradesProvider>().grades;
    
    final result = CalculateTargetGrades().call(
      targetGpa: widget.targetGpa,
      currentCredits: widget.currentCredits,
      currentGpa: widget.currentGpa,
      requirements: reqs,
      activeGrades: activeGrades,
    );

    setState(() {
      _result = result;
      _calculated = true;
    });
  }

  @override
  void dispose() {
    for (var row in _rows) {
      row.countCtrl.dispose();
      row.creditCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int currentInputCrd = _currentInputCredits;
    final bool isExact = currentInputCrd == widget.remainingCredits;

    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lộ trình',
                style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExact ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentInputCrd / ${widget.remainingCredits} TC',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isExact ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._rows.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var row = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              controller: row.countCtrl,
                              hint: 'Số môn',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _onInputChanged(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('x', style: AppTextStyles.bodyLarge),
                          ),
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              controller: row.creditCtrl,
                              hint: 'Tín chỉ',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _onInputChanged(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                            onPressed: _rows.length > 1 ? () => _removeRow(idx) : null,
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text('Thêm loại', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    onPressed: _isValid ? _calculate : null,
                    label: 'Tính toán',
                  ),

                  if (_calculated) ...[
                    const SizedBox(height: 24),
                    ..._buildResultUI(colors),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildResultUI(AppColorsData colors) {
    if (_result == null) {
      return [
        Center(
          child: Text(
            'Rất tiếc, với số tín chỉ này bạn không thể chạm mốc GPA mục tiêu dù có full A+ nhé! 😢',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        )
      ];
    }

    Set<int> uniqueCredits = {};
    Set<String> uniqueLetters = {};
    Map<String, Map<int, int>> matrix = {};

    for (var act in _result!) {
      String letter = act.grade.letter;
      int tc = act.subjectCredits;

      uniqueCredits.add(tc);
      uniqueLetters.add(letter);

      matrix.putIfAbsent(letter, () => {});
      matrix[letter]![tc] = (matrix[letter]![tc] ?? 0) + 1;
    }

    List<int> sortedCredits = uniqueCredits.toList()..sort();

    final allGrades = context.read<GradesProvider>().grades;
    List<String> sortedLetters = [];
    for (var g in allGrades) {
      if (uniqueLetters.contains(g.letter)) {
        sortedLetters.add(g.letter);
      }
    }

    List<Widget> widgets = [];

    List<TableRow> rows = [];
    
    List<Widget> headerCells = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          '',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(color: colors.textSecondary),
        ),
      ),
    ];
    for (var tc in sortedCredits) {
      headerCells.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            '$tc tín',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }
    
    rows.add(
      TableRow(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider)),
        ),
        children: headerCells,
      ),
    );

    for (int i = 0; i < sortedLetters.length; i++) {
      var letter = sortedLetters[i];
      final gradeColor = AppColors.letterColor(letter);
      final isLast = i == sortedLetters.length - 1;

      List<Widget> cells = [];
      cells.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                letter,
                style: AppTextStyles.labelLarge.copyWith(
                  color: gradeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );

      for (var tc in sortedCredits) {
        int count = matrix[letter]?[tc] ?? 0;
        cells.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Center(
              child: Text(
                count > 0 ? '$count môn' : '',
                style: AppTextStyles.headingSmall.copyWith(
                  color: count > 0 ? colors.textPrimary : colors.textSecondary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        );
      }

      rows.add(
        TableRow(
          decoration: BoxDecoration(
            border: isLast ? null : Border(bottom: BorderSide(color: colors.divider)),
          ),
          children: cells,
        ),
      );
    }

    widgets.add(
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: rows,
                ),
              ),
            );
          },
        ),
      ),
    );

    return widgets;
  }
}

class _SubjectInputRow {
  final TextEditingController countCtrl;
  final TextEditingController creditCtrl;
  _SubjectInputRow(this.countCtrl, this.creditCtrl);
}
