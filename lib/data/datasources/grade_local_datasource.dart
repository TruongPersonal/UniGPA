import 'package:hive_flutter/hive_flutter.dart';
import 'package:unigpa/data/models/grade.dart';

class GradeLocalDatasource {
  static const String boxName = 'grades';

  Box<Grade> get _box => Hive.box<Grade>(boxName);

  List<Grade> getAll() => _box.values.toList();

  Future<void> update(int index, Grade grade) => _box.putAt(index, grade);

  bool get isEmpty => _box.isEmpty;

  Future<void> addAll(List<Grade> grades) => _box.addAll(grades);
}
