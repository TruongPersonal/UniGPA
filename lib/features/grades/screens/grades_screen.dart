import 'package:flutter/material.dart';
import '../widgets/semester_management_view.dart';
import '../widgets/grade_config_view.dart';
import '../widgets/grades_list_view.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        GradesListView(),
        SemesterManagementView(),
        GradeConfigView(),
      ],
    );
  }
}
