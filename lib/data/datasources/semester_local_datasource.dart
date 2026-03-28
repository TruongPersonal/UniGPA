import 'package:hive_flutter/hive_flutter.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/datasources/subject_local_datasource.dart';

class SemesterLocalDatasource {
  static const String boxName = 'semesters';

  Box<AcademicSemester> get _box => Hive.box<AcademicSemester>(boxName);

  List<AcademicSemester> getAll() => _box.values.toList();

  Future<void> add(AcademicSemester semester) async {

    final alreadyExists = _box.values.any(
      (s) => s.year.start == semester.year.start && s.semester == semester.semester,
    );
    if (alreadyExists) return;
    await _box.add(semester);
  }

  Future<void> delete(AcademicSemester semester) async {
    final key = _box.keys.firstWhere((k) {
      final s = _box.get(k) as AcademicSemester;
      return s.year.start == semester.year.start &&
          s.semester == semester.semester;
    }, orElse: () => null);

    if (key != null) await _box.delete(key);
  }

  Future<void> clear() => _box.clear();

  bool hasSubjects(AcademicSemester semester) {
    final subjects = Hive.box<Subject>(SubjectLocalDatasource.boxName).values;
    return subjects.any(
      (s) =>
          s.semester.year.start == semester.year.start &&
          s.semester.semester == semester.semester,
    );
  }
}
