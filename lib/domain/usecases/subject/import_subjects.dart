import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class ImportSubjects {
  ImportSubjects(this._subjectRepo, this._semesterRepo);

  final SubjectRepository _subjectRepo;
  final SemesterRepository _semesterRepo;

  Future<void> call({
    required List<Subject> newSubjects,
    required List<Subject> existingSubjects,
  }) async {
    final Set<String> subjectKeys = existingSubjects.map((s) =>
      '${s.name.trim().toLowerCase()}_${s.semester.year.start}_${s.semester.semester}'
    ).toSet();

    final Set<String> addedSemesters = {};

    for (final s in newSubjects) {

      final semKey = '${s.semester.year.start}_${s.semester.semester}';
      if (!addedSemesters.contains(semKey)) {
        await _semesterRepo.add(s.semester);
        addedSemesters.add(semKey);
      }

      final sKey = '${s.name.trim().toLowerCase()}_${s.semester.year.start}_${s.semester.semester}';

      if (!subjectKeys.contains(sKey)) {
        await _subjectRepo.add(s);
        subjectKeys.add(sKey);
      }
    }
  }
}
