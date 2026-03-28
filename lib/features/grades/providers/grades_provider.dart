import 'package:flutter/material.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/domain/repositories/subject_repository.dart';
import 'package:unigpa/domain/repositories/grade_repository.dart';
import 'package:unigpa/domain/usecases/gpa/find_grade_for_score.dart';
import 'package:unigpa/domain/usecases/gpa/calculate_cumulative_gpa.dart';
import 'package:unigpa/domain/usecases/gpa/calculate_average_10.dart';
import 'package:unigpa/domain/usecases/subject/import_subjects.dart';

class GradesProvider extends ChangeNotifier {
  GradesProvider({
    required SubjectRepository subjectRepository,
    required GradeRepository gradeRepository,
    required FindGradeForScore findGradeForScore,
    required CalculateCumulativeGpa calculateCumulativeGpa,
    required CalculateAverage10 calculateAverage10,
    required ImportSubjects importSubjects,
  })  : _subjectRepo = subjectRepository,
        _gradeRepo = gradeRepository,
        _findGrade = findGradeForScore,
        _calculateCumGpa = calculateCumulativeGpa,
        _calculateAverage10 = calculateAverage10,
        _importSubjects = importSubjects {
    _loadData();
  }

  final SubjectRepository _subjectRepo;
  final GradeRepository _gradeRepo;
  final FindGradeForScore _findGrade;
  final CalculateCumulativeGpa _calculateCumGpa;
  final CalculateAverage10 _calculateAverage10;
  final ImportSubjects _importSubjects;

  List<Subject> _subjects = [];
  List<Grade> _grades = [];

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Grade> get grades => List.unmodifiable(_grades);

  List<Subject> get _gradedSubjects => _subjects.where((s) {
    if (s.finalPoint10 == null) return false;
    return _findGrade(point10: s.finalPoint10, grades: _grades) != null;
  }).toList();

  int get totalRegisteredCredits => _gradedSubjects.fold(0, (sum, s) => sum + s.credits);

  int get totalSubjectsCount => _gradedSubjects.length;

  int get totalCredits {
    return _gradedSubjects.where((s) {
      final g = _findGrade(point10: s.finalPoint10, grades: _grades);
      return g != null && g.letter != 'F';
    }).fold(0, (sum, s) => sum + s.credits);
  }

  double? get currentGPA => _calculateCumGpa(subjects: _subjects, grades: _grades, includeFail: false);

  double? calculateGPA(List<Subject> subjects, {bool includeFail = true}) {
    return _calculateCumGpa(subjects: subjects, grades: _grades, includeFail: includeFail);
  }

  double? calculateAvg10(List<Subject> subjects) {
    return _calculateAverage10(subjects);
  }

  Grade? getGrade(double? score) {
    return _findGrade(point10: score, grades: _grades);
  }

  int calculatePassedCredits(List<Subject> subjects) {
    return subjects.where((s) {
      final g = getGrade(s.finalPoint10);
      return g?.isPassing ?? false;
    }).fold(0, (sum, s) => sum + s.credits);
  }

  int calculateAttemptedCredits(List<Subject> subjects) {
    return subjects.where((s) {
      return getGrade(s.finalPoint10) != null;
    }).fold(0, (sum, s) => sum + s.credits);
  }

  Future<void> addSubject(Subject subject) async {
    await _subjectRepo.add(subject);
    _loadData();
  }

  Future<void> deleteSubject(Subject subject) async {
    _subjects.removeWhere(
      (s) =>
          s.name == subject.name &&
          s.semester.year.start == subject.semester.year.start &&
          s.semester.semester == subject.semester.semester,
    );
    notifyListeners();
    await _subjectRepo.delete(subject);
    _loadData();
  }

  Future<void> updateSubject(int index, Subject updated) async {
    await _subjectRepo.update(index, updated);
    _loadData();
  }

  Future<void> importSubjectsFromCsv(List<Subject> newSubjects) async {
    await _importSubjects(
      newSubjects: newSubjects,
      existingSubjects: _subjects,
    );
    _loadData();
  }

  Future<void> deleteSubjects(List<Subject> subjects) async {
    for (final subject in subjects) {
      _subjects.removeWhere(
        (s) =>
            s.name == subject.name &&
            s.semester.year.start == subject.semester.year.start &&
            s.semester.semester == subject.semester.semester,
      );
    }
    notifyListeners();
    await _subjectRepo.deleteMultiple(subjects);
    _loadData();
  }

  Future<void> clearAllData() async {
    await _subjectRepo.clear();
    _loadData();
  }

  void reload() => _loadData();

  void _loadData() {
    _subjects = _subjectRepo.getAll();
    _grades = _gradeRepo.getAll();
    notifyListeners();
  }
}
