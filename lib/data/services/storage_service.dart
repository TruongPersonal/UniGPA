import 'package:hive_flutter/hive_flutter.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';

class StorageService {
  static const String _gradeBoxName = 'grades';
  static const String _subjectBoxName = 'subjects';
  static const String _semesterBoxName = 'semesters';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    final gradeBox = await Hive.openBox<Grade>(_gradeBoxName);
    await Hive.openBox<Subject>(_subjectBoxName);
    await Hive.openBox<AcademicSemester>(_semesterBoxName);
    await Hive.openBox(_settingsBoxName);

    if (gradeBox.isEmpty) {
      await gradeBox.addAll(_defaultGrades());
    }
  }

  static int getThemeMode() =>
      Hive.box(_settingsBoxName).get('themeMode', defaultValue: 0) as int;

  static Future<void> setThemeMode(int index) async =>
      Hive.box(_settingsBoxName).put('themeMode', index);

  static List<Grade> _defaultGrades() => [
    Grade(letter: 'A+', point4: 4.0, startPoint10: 9.5, endPoint10: 10.0),
    Grade(letter: 'A', point4: 3.7, startPoint10: 8.5, endPoint10: 9.4),
    Grade(letter: 'B+', point4: 3.5, startPoint10: 8.0, endPoint10: 8.4),
    Grade(letter: 'B', point4: 3.0, startPoint10: 7.0, endPoint10: 7.9),
    Grade(letter: 'C+', point4: 2.5, startPoint10: 6.5, endPoint10: 6.9),
    Grade(letter: 'C', point4: 2.0, startPoint10: 5.5, endPoint10: 6.4),
    Grade(letter: 'D+', point4: 1.5, startPoint10: 5.0, endPoint10: 5.4),
    Grade(letter: 'D', point4: 1.0, startPoint10: 4.0, endPoint10: 4.9),
    Grade(letter: 'F', point4: 0.0, startPoint10: 0.0, endPoint10: 3.9),
  ];

  static List<Grade> getAllGrades() =>
      Hive.box<Grade>(_gradeBoxName).values.toList();

  static Future<void> updateGrade(int index, Grade grade) async =>
      Hive.box<Grade>(_gradeBoxName).putAt(index, grade);

  static List<Subject> getAllSubjects() =>
      Hive.box<Subject>(_subjectBoxName).values.toList();

  static Future<void> addSubject(Subject subject) async =>
      Hive.box<Subject>(_subjectBoxName).add(subject);

  static Future<void> updateSubject(int index, Subject subject) async =>
      Hive.box<Subject>(_subjectBoxName).putAt(index, subject);

  static Future<void> deleteSubject(Subject subject) async {
    final box = Hive.box<Subject>(_subjectBoxName);
    final key = box.keys.firstWhere((k) {
      final s = box.get(k) as Subject;
      return s.name == subject.name &&
          s.semester.semester == subject.semester.semester &&
          s.semester.year.start == subject.semester.year.start;
    }, orElse: () => null);

    if (key != null) await box.delete(key);
  }

  static Future<void> deleteSubjects(List<Subject> subjects) async {
    final box = Hive.box<Subject>(_subjectBoxName);
    final keysToDelete = <dynamic>[];

    for (final subject in subjects) {
      final key = box.keys.firstWhere((k) {
        final s = box.get(k) as Subject;
        return s.name == subject.name &&
            s.semester.semester == subject.semester.semester &&
            s.semester.year.start == subject.semester.year.start;
      }, orElse: () => null);
      if (key != null) keysToDelete.add(key);
    }

    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
    }
  }

  static Future<void> clearSubjects() async =>
      Hive.box<Subject>(_subjectBoxName).clear();

  static Future<void> clearSemesters() async =>
      Hive.box<AcademicSemester>(_semesterBoxName).clear();

  static List<AcademicSemester> getAllSemesters() =>
      Hive.box<AcademicSemester>(_semesterBoxName).values.toList();

  static Future<void> addSemester(AcademicSemester semester) async =>
      Hive.box<AcademicSemester>(_semesterBoxName).add(semester);

  static Future<void> deleteSemester(AcademicSemester semester) async {
    final box = Hive.box<AcademicSemester>(_semesterBoxName);
    final key = box.keys.firstWhere((k) {
      final s = box.get(k) as AcademicSemester;
      return s.year.start == semester.year.start &&
          s.semester == semester.semester;
    }, orElse: () => null);

    if (key != null) {
      await box.delete(key);
    }
  }

  static bool semesterHasSubjects(AcademicSemester semester) {
    final subjects = getAllSubjects();
    return subjects.any(
      (s) =>
          s.semester.year.start == semester.year.start &&
          s.semester.semester == semester.semester,
    );
  }
}
