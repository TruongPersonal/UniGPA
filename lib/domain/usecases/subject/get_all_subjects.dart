import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';

class GetAllSubjects {
  GetAllSubjects(this._repository);

  final SubjectRepository _repository;

  List<Subject> call() => _repository.getAll();
}
