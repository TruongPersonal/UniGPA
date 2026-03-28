import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';

class AddSubject {
  AddSubject(this._repository);

  final SubjectRepository _repository;

  Future<void> call(Subject subject) => _repository.add(subject);
}
