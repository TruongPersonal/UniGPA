import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unigpa/features/grades/providers/grades_provider.dart';
import '../widgets/gpa_summary_card.dart';
import '../widgets/target_gpa_calculator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GradesProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GpaSummaryCard(
                  gpa: provider.currentGPA,
                  totalCredits: provider.totalCredits,
                  totalRegisteredCredits: provider.totalRegisteredCredits,
                  subjectCount: provider.totalSubjectsCount,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(
                child: TargetGpaCalculator(
                  currentGPA: provider.currentGPA,
                  currentCredits: provider.totalCredits,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
