import 'package:unigpa/data/models/grade.dart';

class SubjectRequirement {
  final int count;
  final int credits;

  SubjectRequirement(this.count, this.credits);
}

class GradeAssignment {
  final Grade grade;
  final int subjectCredits;

  GradeAssignment(this.grade, this.subjectCredits);
}

class CalculateTargetGrades {
  /// Dynamic Programming - Knapsack variant
  /// Tìm tổ hợp điểm chữ cho các môn học sao cho tổng điểm đạt mức yêu cầu với ĐỘ LỆCH PHƯƠNG SAI nhỏ nhất.
  List<GradeAssignment>? call({
    required double targetGpa,
    required int currentCredits,
    required double currentGpa,
    required List<SubjectRequirement> requirements,
    required List<Grade> activeGrades,
  }) {
    int remainingCredits = requirements.fold(0, (sum, req) => sum + req.count * req.credits);
    if (remainingCredits <= 0) return null;

    final targetTotalPoints = targetGpa * (currentCredits + remainingCredits);
    final currentTotalPoints = currentGpa * currentCredits;
    final neededPoints = targetTotalPoints - currentTotalPoints;

    final grades = activeGrades.where((g) => g.isActive && g.point4 != null).toList()
      ..sort((a, b) => a.point4!.compareTo(b.point4!));

    if (grades.isEmpty) return null;

    List<int> subjectCredits = [];
    for (var req in requirements) {
      for (int i = 0; i < req.count; i++) {
        subjectCredits.add(req.credits);
      }
    }

    int numSubjects = subjectCredits.length;
    double neededAvg = neededPoints / remainingCredits;

    List<Map<int, double>> minVar = List.generate(numSubjects + 1, (_) => {});
    List<Map<int, Grade>> choice = List.generate(numSubjects + 1, (_) => {});
    List<Map<int, int>> prevSum = List.generate(numSubjects + 1, (_) => {});

    minVar[0][0] = 0.0;

    for (int i = 0; i < numSubjects; i++) {
      int c = subjectCredits[i];
      for (int s in minVar[i].keys) {
        double currentVar = minVar[i][s]!;
        
        for (var grade in grades) {
          int gradePointInt = (grade.point4! * 10).round();
          int newS = s + gradePointInt * c;
          
          double cost = currentVar + (grade.point4! - neededAvg) * (grade.point4! - neededAvg) * c;
          
          if (!minVar[i + 1].containsKey(newS) || cost < minVar[i + 1][newS]!) {
            minVar[i + 1][newS] = cost;
            choice[i + 1][newS] = grade;
            prevSum[i + 1][newS] = s;
          }
        }
      }
    }

    int targetS = (neededPoints * 10).ceil();
    int? bestS;

    final possibleSums = minVar[numSubjects].keys.toList()..sort();
    
    for (int s in possibleSums) {
      if (s >= targetS) {
        bestS = s;
        break;
      }
    }

    if (bestS == null) return null; 

    List<GradeAssignment> result = [];
    int currentS = bestS;
    
    for (int i = numSubjects; i > 0; i--) {
      Grade g = choice[i][currentS]!;
      result.add(GradeAssignment(g, subjectCredits[i - 1]));
      currentS = prevSum[i][currentS]!;
    }

    return result.reversed.toList();
  }
}
