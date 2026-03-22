import 'package:flutter/material.dart';

import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/services/storage_service.dart';
import 'package:unigpa/data/providers/semester_provider.dart';

class GPAProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  List<Grade> _grades = [];

  GPAProvider() {
    _loadData();
  }

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Grade> get grades => List.unmodifiable(_grades);

  int get totalRegisteredCredits =>
      _subjects.where((s) => s.finalPoint10 != null).fold(0, (sum, s) => sum + s.credits);

  int get totalSubjectsCount =>
      _subjects.where((s) => s.finalPoint10 != null).length;

  int get totalCredits {
    int credits = 0;
    for (final subject in _subjects.where((s) => s.finalPoint10 != null)) {
      final grade = _findGradeFor(subject.finalPoint10);
      if (grade != null && grade.letter != 'F') {
        credits += subject.credits;
      }
    }
    return credits;
  }

  double get currentGPA {
    final validSubjects = _subjects.where((s) => s.finalPoint10 != null);
    if (validSubjects.isEmpty) return 0.0;

    double totalWeightedPoints = 0;
    double totalCredits = 0;

    for (final subject in validSubjects) {
      final grade = _findGradeFor(subject.finalPoint10);
      if (grade == null || grade.letter == 'F') continue;

      totalWeightedPoints += grade.point4! * subject.credits;
      totalCredits += subject.credits;
    }

    return totalCredits == 0 ? 0.0 : totalWeightedPoints / totalCredits;
  }

  Future<void> addSubject(Subject subject) async {
    await StorageService.addSubject(subject);
    _loadData();
  }

  Future<void> deleteSubject(Subject subject) async {
    _subjects.removeWhere((s) => s.name == subject.name && s.semester.year.start == subject.semester.year.start && s.semester.semester == subject.semester.semester);
    notifyListeners();

    await StorageService.deleteSubject(subject);
    _loadData();
  }

  Future<void> updateSubject(int index, Subject updated) async {
    await StorageService.updateSubject(index, updated);
    _loadData();
  }

  Future<void> importSubjects(List<Subject> newSubjects, SemesterProvider semesterProvider) async {
    for (final s in newSubjects) {
      // Ensure the semester exists first
      await semesterProvider.addSemester(
        year: s.semester.year,
        semesterNumber: s.semester.semester,
      );

      final exists = _subjects.any((existing) =>
          existing.name == s.name &&
          existing.semester.year.start == s.semester.year.start &&
          existing.semester.semester == s.semester.semester);
      if (!exists) {
        await StorageService.addSubject(s);
      }
    }
    _loadData();
  }

  void reload() => _loadData();

  void _loadData() {
    _subjects = StorageService.getAllSubjects();
    _grades = StorageService.getAllGrades();
    notifyListeners();
  }

  Grade? _findGradeFor(double? point10) {
    if (point10 == null) return null;
    try {
      return _grades.firstWhere(
        (g) =>
            g.isActive &&
            g.startPoint10 != null &&
            g.endPoint10 != null &&
            point10 >= g.startPoint10! &&
            point10 <= g.endPoint10!,
      );
    } catch (_) {
      return null;
    }
  }
}
