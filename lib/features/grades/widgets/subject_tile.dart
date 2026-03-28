import 'package:flutter/material.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/domain/usecases/gpa/find_grade_for_score.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/core/widgets/app_list_tile.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/features/grades/widgets/add_subject_sheet.dart';
import 'package:unigpa/core/utils/number_formatter.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.subjectIndex,
    required this.grades,
    required this.showDivider,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  final Subject subject;
  final int subjectIndex;
  final List<Grade> grades;
  final bool showDivider;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = subject.finalPoint10 != null;
    final grade = isCompleted
        ? FindGradeForScore()(
            point10: subject.finalPoint10,
            grades: grades,
          )
        : null;

    final letterGrade = grade?.letter ?? 'N/A';
    final point4 = grade?.point4 ?? 0.0;
    final gradeColor = grade != null
        ? AppColors.letterColor(letterGrade)
        : colors.textHint;

    Widget trailingContent;
    if (isCompleted) {
      if (grade != null) {

        trailingContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _fmt(subject.finalPoint10!),
              style: AppTextStyles.headingSmall.copyWith(color: gradeColor),
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
            Text(
              _fmt(subject.finalPoint10!),
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              'N/A',
              style: AppTextStyles.bodySmall.copyWith(color: colors.textHint),
            ),
          ],
        );
      }
    } else {

      trailingContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'N/A',
            style: AppTextStyles.labelLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            'N/A',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textHint),
          ),
        ],
      );
    }

    final tile = AppListTile(
      onTap: isSelectionMode
          ? onToggleSelection
          : () => showAddSubjectSheet(
                context,
                editIndex: subjectIndex,
                editSubject: subject,
              ),
      onLongPress: onToggleSelection,
      leading: isSelectionMode
          ? Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : colors.textHint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : colors.textHint,
              ),
            )
          : Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  letterGrade,
                  style: AppTextStyles.headingSmall.copyWith(color: gradeColor),
                ),
              ),
            ),
      title: subject.name,
      subtitle: '${subject.credits} tín chỉ',
      trailing: isSelectionMode ? null : trailingContent,
      showDivider: showDivider,
    );

    if (isSelectionMode) return tile;

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
      child: tile,
    );
  }

  String _fmt(double v) => NumberFormatter.format(v);

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
