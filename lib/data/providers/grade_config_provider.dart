import 'package:flutter/material.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/services/storage_service.dart';

class GradeConfigProvider extends ChangeNotifier {
  List<Grade> _grades = [];

  GradeConfigProvider() {
    _loadData();
  }

  List<Grade> get grades => List.unmodifiable(_grades);

  List<Grade> get activeGrades => _grades.where((g) => g.isActive).toList();

  Future<void> updateGrade(int index, Grade updated) async {
    await StorageService.updateGrade(index, updated);
    _loadData();
  }

  Future<void> toggleActive(int index) async {
    final grade = _grades[index];
    final updated = Grade(
      letter: grade.letter,
      point4: grade.point4,
      startPoint10: grade.startPoint10,
      endPoint10: grade.endPoint10,
      isActive: !grade.isActive,
    );
    await StorageService.updateGrade(index, updated);
    _loadData();
  }

  void reload() => _loadData();

  void _loadData() {
    _grades = StorageService.getAllGrades();
    notifyListeners();
  }
}
