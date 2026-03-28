import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';

class UpdateSubject {
  UpdateSubject(this._repository);

  final SubjectRepository _repository;

  Future<void> call(int index, Subject subject) =>
      _repository.update(index, subject);
}
