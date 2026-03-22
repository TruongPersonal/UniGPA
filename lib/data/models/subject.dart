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
  double point10;
  @HiveField(3)
  AcademicSemester semester;

  Subject({
    required this.name,
    required this.credits,
    required this.point10,
    required this.semester,
  });

  double getPoint4(List<Grade> grades) {
    for (var grade in grades) {
      if (point10 >= grade.startPoint10! && point10 <= grade.endPoint10!) {
        return grade.point4!;
      }
    }
    return 0.0;
  }

  String getGradeLetter(List<Grade> grades) {
    for (var grade in grades) {
      if (point10 >= grade.startPoint10! && point10 <= grade.endPoint10!) {
        return grade.letter;
      }
    }
    return 'F';
  }
}
