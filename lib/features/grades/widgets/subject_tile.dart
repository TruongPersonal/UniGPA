import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/utils/gpa_calculator.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/features/grades/screens/add_subject_screen.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.subjectIndex,
    required this.grades,
    required this.showDivider,
    required this.onDelete,
  });

  final Subject subject;
  final int subjectIndex;
  final List<Grade> grades;
  final bool showDivider;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = subject.finalPoint10 != null;
    final grade = isCompleted ? GpaCalculator.findGradeFor(
      point10: subject.finalPoint10,
      grades: grades,
    ) : null;
    
    final letterGrade = isCompleted ? (grade?.letter ?? 'F') : 'N/A';
    final point4 = grade?.point4 ?? 0.0;
    final gradeColor = isCompleted ? AppColors.letterColor(letterGrade) : colors.textHint;

    Widget trailingContent;
    if (isCompleted) {
      trailingContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _fmt(subject.finalPoint10!),
            style: AppTextStyles.headingSmall.copyWith(
              color: gradeColor,
            ),
          ),
          Text(
            '${_fmt(point4)} / 4.0',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      );
    } else {
      trailingContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('N/A', style: AppTextStyles.labelLarge.copyWith(color: colors.textSecondary)),
          Text('N/A', style: AppTextStyles.bodySmall.copyWith(color: colors.textHint)),
        ],
      );
    }

    return Dismissible(
      key: ValueKey('sub_${subjectIndex}_${subject.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
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
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      child: AppListTile(
        onTap: () => showAddSubjectSheet(
          context,
          editIndex: subjectIndex,
          editSubject: subject,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              letterGrade,
              style: AppTextStyles.headingSmall.copyWith(
                color: gradeColor,
              ),
            ),
          ),
        ),
        title: subject.name,
        subtitle: '${subject.credits} tín chỉ',
        trailing: trailingContent,
        showDivider: showDivider,
      ),
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá môn học?'),
        content: Text('Bạn có chắc muốn xoá "${subject.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}
