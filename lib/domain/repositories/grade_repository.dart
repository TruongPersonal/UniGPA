import 'package:unigpa/data/models/grade.dart';

abstract class GradeRepository {
  List<Grade> getAll();
  Future<void> update(int index, Grade grade);
  Future<void> addAll(List<Grade> grades);
}
