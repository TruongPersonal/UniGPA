import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/core/widgets/empty_state.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/features/grades/widgets/semester_gpa_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/semester_section.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GPAProvider, SemesterProvider>(
      builder: (context, gpaProvider, semesterProvider, _) {
        final subjects = gpaProvider.subjects;
        final grades = gpaProvider.grades;
        final semesters = semesterProvider.semesters;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: CustomScrollView(
            slivers: [
              if (semesters.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.calendar_today_rounded,
                    title: 'Chưa có học vụ nào',
                  ),
                )
              else if (subjects.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.school_rounded,
                    title: 'Chưa có môn học nào',
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                    child: SemesterGpaChart(
                      subjects: subjects,
                      grades: grades,
                    ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, semIdx) {
                        final semester = semesters[semIdx];

                        final semSubjects = <Subject>[];
                        for (var i = 0; i < subjects.length; i++) {
                          final s = subjects[i];
                          if (s.semester.year.start == semester.year.start &&
                              s.semester.semester == semester.semester) {
                            semSubjects.add(s);
                          }
                        }

                        if (semSubjects.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: SemesterSection(
                            semester: semester,
                            subjects: semSubjects,
                            grades: grades,
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
                      },
                      childCount: semesters.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
