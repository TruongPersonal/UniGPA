import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/features/grades/providers/grade_config_provider.dart';

class TargetScoresTable extends StatelessWidget {
  const TargetScoresTable({super.key, required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    if (subject.processWeight == null) return const SizedBox();
    if (subject.processWeight! > 0 && subject.processPoint == null) {
      return const SizedBox();
    }

    final activeGrades = context.watch<GradeConfigProvider>().grades.where((g) => g.isActive).toList();
    if (activeGrades.isEmpty) return const SizedBox();

    final pWeight = subject.processWeight!;
    final pPoint = subject.processPoint ?? 0.0;
    final wEnd = 1 - pWeight;

    if (wEnd <= 0) return const SizedBox();

    final colors = context.colors;
    final dividerColor = colors.divider;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
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
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Loại',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Tổng kết',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Cần đạt',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                ...activeGrades.map((grade) {
                  final targetScore = grade.startPoint10!;
                  double needed = (targetScore - pPoint * pWeight) / wEnd;
                  String text = '';
                  Color textColor = colors.textPrimary;

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
                                color: AppColors.letterColor(
                                  grade.letter,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  grade.letter,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.letterColor(grade.letter),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '>= ${grade.startPoint10}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            text,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
