import 'package:hive/hive.dart';
import 'package:unigpa/data/models/year.dart';

part 'academic_semester.g.dart';

@HiveType(typeId: 0)
class AcademicSemester {
  @HiveField(0)
  Year year;
  @HiveField(1)
  int semester;

  AcademicSemester({required this.year, required this.semester});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicSemester &&
          other.semester == semester &&
          other.year.start == year.start;

  @override
  int get hashCode => Object.hash(semester, year.start);
}
