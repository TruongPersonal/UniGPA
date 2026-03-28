import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class DeleteSemester {
  DeleteSemester(this._repository);

  final SemesterRepository _repository;

  Future<bool> call(AcademicSemester semester) async {
    if (_repository.hasSubjects(semester)) return false;
    await _repository.delete(semester);
    return true;
  }
}
