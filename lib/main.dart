import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/year.dart';

import 'package:unigpa/data/datasources/subject_local_datasource.dart';
import 'package:unigpa/data/datasources/semester_local_datasource.dart';
import 'package:unigpa/data/datasources/grade_local_datasource.dart';
import 'package:unigpa/data/datasources/settings_local_datasource.dart';

import 'package:unigpa/data/repositories/subject_repository_impl.dart';
import 'package:unigpa/data/repositories/semester_repository_impl.dart';
import 'package:unigpa/data/repositories/grade_repository_impl.dart';
import 'package:unigpa/data/repositories/settings_repository_impl.dart';

import 'package:unigpa/domain/usecases/gpa/find_grade_for_score.dart';
import 'package:unigpa/domain/usecases/gpa/calculate_cumulative_gpa.dart';
import 'package:unigpa/domain/usecases/gpa/calculate_average_10.dart';
import 'package:unigpa/domain/usecases/subject/import_subjects.dart';

import 'package:unigpa/features/grades/providers/grades_provider.dart';
import 'package:unigpa/features/grades/providers/semester_provider.dart';
import 'package:unigpa/features/settings/providers/theme_provider.dart';
import 'package:unigpa/features/grades/providers/grade_config_provider.dart';

import 'package:unigpa/core/theme/app_theme.dart';
import 'package:unigpa/features/auth/providers/auth_provider.dart';
import 'package:unigpa/features/auth/screens/auth_screen.dart';
import 'package:unigpa/features/home/screens/main_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GradeAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(AcademicSemesterAdapter());
  Hive.registerAdapter(YearAdapter());

  final gradeBox = await Hive.openBox<Grade>(GradeLocalDatasource.boxName);
  await Hive.openBox<Subject>(SubjectLocalDatasource.boxName);
  await Hive.openBox<AcademicSemester>(SemesterLocalDatasource.boxName);
  await Hive.openBox(SettingsLocalDatasource.boxName);

  if (gradeBox.isEmpty) {
    await gradeBox.addAll([
      Grade(letter: 'A+', point4: 4.0, startPoint10: 9.5, endPoint10: 10.0, isActive: false),
      Grade(letter: 'A', point4: 4.0, startPoint10: 8.5, endPoint10: 10.0),
      Grade(letter: 'B+', point4: 3.5, startPoint10: 8.0, endPoint10: 8.4, isActive: false),
      Grade(letter: 'B', point4: 3.0, startPoint10: 7.0, endPoint10: 8.4),
      Grade(letter: 'C+', point4: 2.5, startPoint10: 6.5, endPoint10: 6.9, isActive: false),
      Grade(letter: 'C', point4: 2.0, startPoint10: 5.5, endPoint10: 6.9),
      Grade(letter: 'D+', point4: 1.5, startPoint10: 5.0, endPoint10: 5.4, isActive: false),
      Grade(letter: 'D', point4: 1.0, startPoint10: 4.0, endPoint10: 5.4),
      Grade(letter: 'F', point4: 0.0, startPoint10: 0.0, endPoint10: 3.9),
    ]);
  }

  final subjectDs = SubjectLocalDatasource();
  final semesterDs = SemesterLocalDatasource();
  final gradeDs = GradeLocalDatasource();
  final settingsDs = SettingsLocalDatasource();

  final subjectRepo = SubjectRepositoryImpl(subjectDs);
  final semesterRepo = SemesterRepositoryImpl(semesterDs);
  final gradeRepo = GradeRepositoryImpl(gradeDs);
  final settingsRepo = SettingsRepositoryImpl(settingsDs);

  final findGrade = FindGradeForScore();
  final calcCumGpa = CalculateCumulativeGpa(findGrade);
  final calcAvg10 = CalculateAverage10();
  final importSubjects = ImportSubjects(subjectRepo, semesterRepo);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(repository: settingsRepo),
          ),
        ChangeNotifierProvider(
          create: (_) => GradesProvider(
            subjectRepository: subjectRepo,
            gradeRepository: gradeRepo,
            findGradeForScore: findGrade,
            calculateCumulativeGpa: calcCumGpa,
            calculateAverage10: calcAvg10,
            importSubjects: importSubjects,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SemesterProvider(repository: semesterRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => GradeConfigProvider(repository: gradeRepo),
        ),
      ],
      child: const UniGpaApp(),
    ),
  );
}

class UniGpaApp extends StatelessWidget {
  const UniGpaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final authProvider = context.watch<AuthProvider>();
    
    return MaterialApp(
      title: 'UniGPA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: authProvider.isInitializing 
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (authProvider.isAuthenticated ? const MainDashboardScreen() : const AuthScreen()),
    );
  }
}
