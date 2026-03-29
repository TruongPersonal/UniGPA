import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/widgets/empty_state.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/features/grades/providers/grades_provider.dart';
import 'package:unigpa/features/grades/providers/semester_provider.dart';
import 'package:unigpa/features/grades/widgets/semester_gpa_chart.dart';
import 'package:unigpa/features/grades/widgets/semester_section.dart';
import 'add_subject_sheet.dart';

class GradesListView extends StatefulWidget {
  const GradesListView({super.key});

  @override
  State<GradesListView> createState() => _GradesListViewState();
}

class _GradesListViewState extends State<GradesListView> {
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
        content: Text('Bạn có chắc muốn xoá $count môn học đã chọn?'),
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
      final provider = context.read<GradesProvider>();
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<GradesProvider, SemesterProvider>(
        builder: (context, gradesProvider, semesterProvider, _) {
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

          final subjects = gradesProvider.subjects;
          if (subjects.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.school_rounded,
                title: 'Chưa có môn học nào',
              ),
            );
          }

          final hasGradedSubjects = subjects.any((s) => s.finalPoint10 != null);
          final hasChartData = hasGradedSubjects && gradesProvider.totalSubjectsCount > 0;
          final subjectsBySemester = gradesProvider.subjectsBySemester;

          return Column(
            children: [
              if (_isSelectionMode)
                _SelectionHeader(
                  selectedCount: _selectedSubjects.length,
                  onExit: _exitSelectionMode,
                  onDelete: () => _deleteSelected(context),
                ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (hasChartData)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        sliver: SliverToBoxAdapter(
                          child: SemesterGpaChart(
                            subjects: subjects,
                            grades: gradesProvider.grades,
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: hasChartData ? 12 : 20,
                        bottom: 24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, semIdx) {
                          final semester = semesters[semIdx];
                          // Lấy môn từ Map O(1) thay List O(N)
                          final semSubjects = subjectsBySemester[semester] ?? [];

                          if (semSubjects.isEmpty) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: SemesterSection(
                              semester: semester,
                              subjects: semSubjects,
                              grades: gradesProvider.grades,
                              isSelectionMode: _isSelectionMode,
                              selectedSubjects: _selectedSubjects,
                              onToggleSelection: _toggleSelection,
                              onDeleteSubject: (subject) {
                                gradesProvider.deleteSubject(subject);
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
      ),
      floatingActionButton: Consumer<SemesterProvider>(
        builder: (context, semesterProvider, _) {
          if (semesterProvider.semesters.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => showAddSubjectSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({
    required this.selectedCount,
    required this.onExit,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onExit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.primary),
            onPressed: onExit,
          ),
          const SizedBox(width: 8),
          Text(
            'Đã chọn $selectedCount',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
