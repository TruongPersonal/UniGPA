import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';

class DeleteSubject {
  DeleteSubject(this._repository);

  final SubjectRepository _repository;

  Future<void> call(Subject subject) => _repository.delete(subject);
}
