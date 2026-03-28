import 'package:unigpa/data/datasources/subject_local_datasource.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  SubjectRepositoryImpl(this._datasource);

  final SubjectLocalDatasource _datasource;

  @override
  List<Subject> getAll() => _datasource.getAll();

  @override
  Future<void> add(Subject subject) => _datasource.add(subject);

  @override
  Future<void> update(int index, Subject subject) =>
      _datasource.update(index, subject);

  @override
  Future<void> delete(Subject subject) => _datasource.delete(subject);

  @override
  Future<void> deleteMultiple(List<Subject> subjects) =>
      _datasource.deleteMultiple(subjects);

  @override
  Future<void> clear() => _datasource.clear();
}
