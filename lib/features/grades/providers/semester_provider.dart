import 'package:flutter/material.dart';

import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/year.dart';
import 'package:unigpa/domain/repositories/semester_repository.dart';

class SemesterProvider extends ChangeNotifier {
  SemesterProvider({required SemesterRepository repository})
      : _repository = repository {
    _loadData();
  }

  final SemesterRepository _repository;

  List<AcademicSemester> _semesters = [];

  List<AcademicSemester> get semesters => List.unmodifiable(_semesters);

  bool get isEmpty => _semesters.isEmpty;

  List<Year> get distinctYears {
    final seen = <String>{};
    final years = <Year>[];
    for (final s in _semesters) {
      final key = '${s.year.start}-${s.year.end}';
      if (seen.add(key)) years.add(s.year);
    }
    years.sort((a, b) => a.start.compareTo(b.start));
    return years;
  }

  List<AcademicSemester> semestersOfYear(Year year) => _semesters
      .where((s) => s.year.start == year.start && s.year.end == year.end)
      .toList()
    ..sort((a, b) => a.semester.compareTo(b.semester));

  Future<void> addSemester({
    required Year year,
    required int semesterNumber,
  }) async {
    final exists = _semesters.any(
      (s) => s.year.start == year.start && s.semester == semesterNumber,
    );
    if (exists) return;

    final semester = AcademicSemester(year: year, semester: semesterNumber);
    await _repository.add(semester);
    _loadData();
  }

  Future<bool> deleteSemester(AcademicSemester semester) async {
    if (_repository.hasSubjects(semester)) return false;

    _semesters.removeWhere(
      (s) =>
          s.year.start == semester.year.start &&
          s.semester == semester.semester,
    );
    notifyListeners();

    await _repository.delete(semester);
    _loadData();
    return true;
  }

  Future<void> deleteAllData() async {
    await _repository.clear();
    _loadData();
  }

  void reload() => _loadData();

  void _loadData() {
    _semesters = _repository.getAll();
    _semesters.sort((a, b) {
      final yearDiff = a.year.start.compareTo(b.year.start);
      return yearDiff != 0 ? yearDiff : a.semester.compareTo(b.semester);
    });
    notifyListeners();
  }
}
