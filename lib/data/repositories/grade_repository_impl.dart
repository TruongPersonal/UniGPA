import 'package:unigpa/data/datasources/grade_local_datasource.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/domain/repositories/grade_repository.dart';

class GradeRepositoryImpl implements GradeRepository {
  GradeRepositoryImpl(this._datasource);

  final GradeLocalDatasource _datasource;

  @override
  List<Grade> getAll() => _datasource.getAll();

  @override
  Future<void> update(int index, Grade grade) =>
      _datasource.update(index, grade);

  @override
  Future<void> addAll(List<Grade> grades) => _datasource.addAll(grades);
}
