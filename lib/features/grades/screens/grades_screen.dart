import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/empty_state.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/features/grades/widgets/semester_gpa_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/semester_section.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  bool _isSelectionMode = false;
  final Set<Subject> _selectedSubjects = {};

  void _toggleSelection(Subject subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
        if (_selectedSubjects.isEmpty) _isSelectionMode = false;
      } else {
        _isSelectionMode = true;
        _selectedSubjects.add(subject);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedSubjects.clear();
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final count = _selectedSubjects.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá môn học'),
        content: Text('Bạn có chắc muốn xoá các môn học?'),
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

    if (confirmed == true) {
      if (!context.mounted) return;
      final provider = context.read<GPAProvider>();
      await provider.deleteSubjects(_selectedSubjects.toList());
      _exitSelectionMode();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xoá $count môn học!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GPAProvider, SemesterProvider>(
      builder: (context, gpaProvider, semesterProvider, _) {
        final subjects = gpaProvider.subjects;
        final grades = gpaProvider.grades;
        final semesters = semesterProvider.semesters;

        if (semesters.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: EmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'Chưa có học vụ nào',
            ),
          );
        }

        if (subjects.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: EmptyState(
              icon: Icons.school_rounded,
              title: 'Chưa có môn học nào',
            ),
          );
        }

        return Column(
          children: [
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.primary),
                      onPressed: _exitSelectionMode,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đã chọn ${_selectedSubjects.length}',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () => _deleteSelected(context),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (gpaProvider.totalSubjectsCount > 0)
                            SemesterGpaChart(subjects: subjects, grades: grades),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, semIdx) {
                        final semester = semesters[semIdx];
                        final semSubjects = subjects
                            .where((s) =>
                                s.semester.year.start == semester.year.start &&
                                s.semester.semester == semester.semester)
                            .toList();

                        if (semSubjects.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: SemesterSection(
                            semester: semester,
                            subjects: semSubjects,
                            grades: grades,
                            isSelectionMode: _isSelectionMode,
                            selectedSubjects: _selectedSubjects,
                            onToggleSelection: _toggleSelection,
                            onDeleteSubject: (subject) {
                              gpaProvider.deleteSubject(subject);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xoá môn học thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: semesters.length),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
