import 'package:unigpa/data/models/academic_semester.dart';

abstract class SemesterRepository {
  List<AcademicSemester> getAll();
  Future<void> add(AcademicSemester semester);
  Future<void> delete(AcademicSemester semester);
  Future<void> clear();
  bool hasSubjects(AcademicSemester semester);
}
