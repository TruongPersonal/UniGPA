import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/year.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class AddSemester {
  AddSemester(this._repository);

  final SemesterRepository _repository;

  Future<void> call({
    required Year year,
    required int semesterNumber,
    required List<AcademicSemester> existing,
  }) async {
    final alreadyExists = existing.any(
      (s) => s.year.start == year.start && s.semester == semesterNumber,
    );
    if (alreadyExists) return;

    final semester = AcademicSemester(year: year, semester: semesterNumber);
    await _repository.add(semester);
  }
}
