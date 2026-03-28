import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class GetAllSemesters {
  GetAllSemesters(this._repository);

  final SemesterRepository _repository;

  List<AcademicSemester> call() => _repository.getAll();
}
