import 'package:flutter/material.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/domain/repositories/grade_repository.dart';

class GradeConfigProvider extends ChangeNotifier {
  GradeConfigProvider({required GradeRepository repository})
      : _repository = repository {
    _loadData();
  }

  final GradeRepository _repository;

  List<Grade> _grades = [];

  List<Grade> get grades => List.unmodifiable(_grades);

  List<Grade> get activeGrades => _grades.where((g) => g.isActive).toList();

  Future<void> updateGrade(int index, Grade updated) async {
    await _repository.update(index, updated);
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
    await _repository.update(index, updated);
    _loadData();
  }

  void reload() => _loadData();

  void _loadData() {
    _grades = _repository.getAll();
    notifyListeners();
  }
}
