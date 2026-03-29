import 'package:unigpa/data/models/subject.dart';

class CalculateAverage10 {
  // Tính điểm trung bình hệ 10
  double? call(List<Subject> subjects) {
    if (subjects.isEmpty) return null;

    double totalWeighted = 0;
    double totalCredits = 0;
    bool hasValue = false;

    for (final subject in subjects) {
      if (subject.finalPoint10 == null) continue;
      
      totalWeighted += subject.finalPoint10! * subject.credits;
      totalCredits += subject.credits;
      hasValue = true;
    }

    if (!hasValue) return null;
    return totalCredits == 0 ? 0.0 : totalWeighted / totalCredits;
  }
}
