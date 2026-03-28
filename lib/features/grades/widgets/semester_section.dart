import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';
import '../../../features/grades/providers/grades_provider.dart';
import 'package:provider/provider.dart';
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
    final provider = context.read<GradesProvider>();
    
    final passedCredits = provider.calculatePassedCredits(subjects);
    final attemptedCredits = provider.calculateAttemptedCredits(subjects);

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
            Text(
              '$passedCredits/$attemptedCredits TC',
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
                final subjectIndex = provider.subjects.indexOf(subject);
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
