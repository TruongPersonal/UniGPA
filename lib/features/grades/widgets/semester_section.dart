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
  });

  final AcademicSemester semester;
  final List<Subject> subjects;

  final List<Grade> grades;
  final void Function(Subject subject) onDeleteSubject;

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
    final totalSemesterCredits = subjects.fold<int>(0, (sum, s) => sum + s.credits);
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
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'GPA: ${semesterGpa.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$passedCredits/$totalSemesterCredits TC',
              style: AppTextStyles.bodySmall
                  .copyWith(color: colors.textSecondary),
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
                final subjectIndex = context.read<GPAProvider>().subjects.indexOf(subject);
                final isLast = i == subjects.length - 1;
                return SubjectTile(
                  subject: subject,
                  subjectIndex: subjectIndex,
                  grades: grades,
                  showDivider: !isLast,
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
