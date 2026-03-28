import 'package:unigpa/data/models/subject.dart';

abstract class SubjectRepository {
  List<Subject> getAll();
  Future<void> add(Subject subject);
  Future<void> update(int index, Subject subject);
  Future<void> delete(Subject subject);
  Future<void> deleteMultiple(List<Subject> subjects);
  Future<void> clear();
}
