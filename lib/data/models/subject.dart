import 'package:unigpa/data/models/academic_semester.dart';
import 'package:hive/hive.dart';

import 'grade.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject {
  @HiveField(0)
  String name;
  @HiveField(1)
  int credits;
  @HiveField(2)
  double? point10;
  @HiveField(3)
  AcademicSemester semester;
  @HiveField(4)
  double? processWeight;
  @HiveField(5)
  double? processPoint;
  @HiveField(6)
  double? examPoint;

  Subject({
    required this.name,
    required this.credits,
    this.point10,
    required this.semester,
    this.processWeight,
    this.processPoint,
    this.examPoint,
  });

  double? get finalPoint10 {
    if (processWeight != null) {
      if (processWeight == 1.0) return processPoint;
      if (processWeight == 0.0) return examPoint;

      if (processPoint != null && examPoint != null) {
        return double.parse(
          (processPoint! * processWeight! + examPoint! * (1 - processWeight!)).toStringAsFixed(1),
        );
      }
    }
    return point10;
  }

  double? getPoint4(List<Grade> grades) {
    if (finalPoint10 == null) return null;
    for (var grade in grades) {
      if (finalPoint10! >= grade.startPoint10! && finalPoint10! <= grade.endPoint10!) {
        return grade.point4;
      }
    }
    return 0.0;
  }

  String? getGradeLetter(List<Grade> grades) {
    if (finalPoint10 == null) return null;
    for (var grade in grades) {
      if (finalPoint10! >= grade.startPoint10! && finalPoint10! <= grade.endPoint10!) {
        return grade.letter;
      }
    }
    return 'F';
  }
}
