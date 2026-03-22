import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:unigpa/core/theme/app_theme.dart';
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/grade.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/year.dart';
import 'package:unigpa/data/providers/grade_config_provider.dart';
import 'package:unigpa/data/providers/gpa_provider.dart';
import 'package:unigpa/data/providers/semester_provider.dart';
import 'package:unigpa/data/providers/theme_provider.dart';
import 'package:unigpa/data/services/storage_service.dart';
import 'package:unigpa/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GradeAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(AcademicSemesterAdapter());
  Hive.registerAdapter(YearAdapter());

  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GPAProvider()),
        ChangeNotifierProvider(create: (_) => SemesterProvider()),
        ChangeNotifierProvider(create: (_) => GradeConfigProvider()),
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
    return MaterialApp(
      title: 'UniGPA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: AppShell(),
    );
  }
}
