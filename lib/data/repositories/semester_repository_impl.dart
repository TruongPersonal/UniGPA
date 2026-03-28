import 'package:unigpa/data/datasources/semester_local_datasource.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class SemesterRepositoryImpl implements SemesterRepository {
  SemesterRepositoryImpl(this._datasource);

  final SemesterLocalDatasource _datasource;

  @override
  List<AcademicSemester> getAll() => _datasource.getAll();

  @override
  Future<void> add(AcademicSemester semester) => _datasource.add(semester);

  @override
  Future<void> delete(AcademicSemester semester) =>
      _datasource.delete(semester);

  @override
  Future<void> clear() => _datasource.clear();

  @override
  bool hasSubjects(AcademicSemester semester) =>
      _datasource.hasSubjects(semester);
}
