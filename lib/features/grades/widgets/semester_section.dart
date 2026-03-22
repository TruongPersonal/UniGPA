import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/utils/gpa_calculator.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';
import '../../../data/providers/gpa_provider.dart';
import 'subject_tile.dart';

class SemesterSection extends StatelessWidget {
  const SemesterSection({
    super.key,
    required this.semester,
    required this.subjects,
    required this.grades,
    required this.onDeleteSubject,
    required this.isSelectionMode,
    required this.selectedSubjects,
    required this.onToggleSelection,
  });

  final AcademicSemester semester;
  final List<Subject> subjects;
  final List<Grade> grades;
  final void Function(Subject subject) onDeleteSubject;
  final bool isSelectionMode;
  final Set<Subject> selectedSubjects;
  final void Function(Subject subject) onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semesterGpa = GpaCalculator.calculateForSemester(
      semesterSubjects: subjects,
      grades: grades,
    );
    final passedCredits = GpaCalculator.passedCreditsOf(
      subjects: subjects,
      grades: grades,
    );
    final totalSemesterCredits = subjects
        .where((s) => s.finalPoint10 != null)
        .fold<int>(0, (sum, s) => sum + s.credits);
    final hasCompleted = subjects.any((s) => s.finalPoint10 != null);
    final badgeColor = AppColors.gpaColor(semesterGpa);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'HK${semester.semester} · ${semester.year.yearDisplay}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasCompleted
                    ? badgeColor.withValues(alpha: 0.1)
                    : colors.textHint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hasCompleted
                    ? 'GPA: ${semesterGpa.toStringAsFixed(2)}'
                    : 'GPA: N/A',
                style: AppTextStyles.bodySmall.copyWith(
                  color: hasCompleted ? badgeColor : colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$passedCredits/$totalSemesterCredits TC',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(subjects.length, (i) {
                final subject = subjects[i];
                final subjectIndex = context
                    .read<GPAProvider>()
                    .subjects
                    .indexOf(subject);
                final isLast = i == subjects.length - 1;
                final isSelected = selectedSubjects.contains(subject);
                return SubjectTile(
                  subject: subject,
                  subjectIndex: subjectIndex,
                  grades: grades,
                  showDivider: !isLast,
                  isSelectionMode: isSelectionMode,
                  isSelected: isSelected,
                  onToggleSelection: () => onToggleSelection(subject),
                  onDelete: () => onDeleteSubject(subject),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
