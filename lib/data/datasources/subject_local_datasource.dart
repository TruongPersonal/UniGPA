import 'package:hive_flutter/hive_flutter.dart';
import 'package:unigpa/data/models/subject.dart';

class SubjectLocalDatasource {
  static const String boxName = 'subjects';

  Box<Subject> get _box => Hive.box<Subject>(boxName);

  List<Subject> getAll() => _box.values.toList();

  Future<void> add(Subject subject) => _box.add(subject);

  Future<void> update(int index, Subject subject) =>
      _box.putAt(index, subject);

  Future<void> delete(Subject subject) async {
    final key = _box.keys.firstWhere((k) {
      final s = _box.get(k) as Subject;
      return s.name == subject.name &&
          s.semester.semester == subject.semester.semester &&
          s.semester.year.start == subject.semester.year.start;
    }, orElse: () => null);

    if (key != null) await _box.delete(key);
  }

  Future<void> deleteMultiple(List<Subject> subjects) async {
    final keysToDelete = <dynamic>[];
    for (final subject in subjects) {
      final key = _box.keys.firstWhere((k) {
        final s = _box.get(k) as Subject;
        return s.name == subject.name &&
            s.semester.semester == subject.semester.semester &&
            s.semester.year.start == subject.semester.year.start;
      }, orElse: () => null);
      if (key != null) keysToDelete.add(key);
    }
    if (keysToDelete.isNotEmpty) await _box.deleteAll(keysToDelete);
  }

  Future<void> clear() => _box.clear();
}
