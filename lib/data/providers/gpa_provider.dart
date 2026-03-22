import 'package:flutter/material.dart';

import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/services/storage_service.dart';

class GPAProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  List<Grade> _grades = [];

  GPAProvider() {
    _loadData();
  }

  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Grade> get grades => List.unmodifiable(_grades);

  int get totalRegisteredCredits =>
      _subjects.fold(0, (sum, s) => sum + s.credits);

  int get totalCredits {
    int credits = 0;
    for (final subject in _subjects) {
      final grade = _findGradeFor(subject.point10);
      if (grade != null && grade.letter != 'F') {
        credits += subject.credits;
      }
    }
    return credits;
  }

  double get currentGPA {
    if (_subjects.isEmpty) return 0.0;

    double totalWeightedPoints = 0;
    double totalCredits = 0;

    for (final subject in _subjects) {
      final grade = _findGradeFor(subject.point10);
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

  void reload() => _loadData();

  void _loadData() {
    _subjects = StorageService.getAllSubjects();
    _grades = StorageService.getAllGrades();
    notifyListeners();
  }

  Grade? _findGradeFor(double point10) {
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
