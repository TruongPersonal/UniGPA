import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';

abstract class GpaCalculator {
  static bool isPassing(Grade? grade) => grade != null && grade.letter != 'F';

  static int passedCreditsOf({
    required List<Subject> subjects,
    required List<Grade> grades,
  }) {
    int total = 0;
    for (final subject in subjects) {
      if (subject.finalPoint10 == null) continue;
      final grade = findGradeFor(point10: subject.finalPoint10, grades: grades);
      if (isPassing(grade)) total += subject.credits;
    }
    return total;
  }

  static double calculateCumulative({
    required List<Subject> subjects,
    required List<Grade> grades,
  }) {
    if (subjects.isEmpty) return 0.0;

    double totalWeighted = 0;
    double totalCredits = 0;

    for (final subject in subjects) {
      if (subject.finalPoint10 == null) continue;
      final grade = findGradeFor(point10: subject.finalPoint10, grades: grades);
      if (grade == null || grade.letter == 'F') continue;

      totalWeighted += grade.point4! * subject.credits;
      totalCredits += subject.credits;
    }

    return totalCredits == 0 ? 0.0 : totalWeighted / totalCredits;
  }

  static double? calculateNeededGPA({
    required double currentGPA,
    required int currentCredits,
    required double targetGPA,
    required int remainingCredits,
  }) {
    if (remainingCredits <= 0) return null;

    final needed =
        (targetGPA * (currentCredits + remainingCredits) -
            currentGPA * currentCredits) /
        remainingCredits;

    if (needed < 0 || needed > 4.0) return null;
    return needed;
  }

  static Grade? findGradeFor({
    required double? point10,
    required List<Grade> grades,
  }) {
    try {
      return grades.firstWhere(
        (g) =>
            g.isActive &&
            g.startPoint10 != null &&
            g.endPoint10 != null &&
            point10 != null &&
            point10 >= g.startPoint10! &&
            point10 <= g.endPoint10!,
      );
    } catch (_) {
      return null;
    }
  }

  static double calculateForSemester({
    required List<Subject> semesterSubjects,
    required List<Grade> grades,
  }) => calculateCumulative(subjects: semesterSubjects, grades: grades);
}
