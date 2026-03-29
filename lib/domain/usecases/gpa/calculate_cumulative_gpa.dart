import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/usecases/gpa/find_grade_for_score.dart';

class CalculateCumulativeGpa {
  CalculateCumulativeGpa(this._findGrade);

  final FindGradeForScore _findGrade;

  // Tính GPA hệ 4 dựa trên danh sách môn học và thang chữ
  // False để bỏ qua các môn rớt (F) khi tính
  double? call({
    required List<Subject> subjects,
    required List<Grade> grades,
    bool includeFail = false,
  }) {
    if (subjects.isEmpty) return null;

    double totalWeighted = 0;
    double totalCredits = 0;
    bool hasValue = false;

    for (final subject in subjects) {
      if (subject.finalPoint10 == null) continue;
      final grade = _findGrade(point10: subject.finalPoint10, grades: grades);
      
      if (grade == null) continue;
      if (!includeFail && grade.letter == 'F') continue;

      totalWeighted += grade.point4! * subject.credits;
      totalCredits += subject.credits;
      hasValue = true;
    }

    if (!hasValue) return null;
    return totalCredits == 0 ? 0.0 : totalWeighted / totalCredits;
  }
}
