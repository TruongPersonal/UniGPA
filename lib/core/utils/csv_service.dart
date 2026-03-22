import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:unigpa/data/models/academic_semester.dart';
import 'package:unigpa/data/models/subject.dart';
import 'package:unigpa/data/models/year.dart';

class CsvService {
  static const List<String> _headers = [
    'year_start',
    'year_end',
    'semester',
    'subject_name',
    'credits',
    'process_weight_percent',
    'process_score',
    'exam_score',
  ];

  static Future<void> exportSubjects(List<Subject> subjects) async {
    final List<List<dynamic>> rows = [_headers];

    for (final s in subjects) {
      rows.add([
        s.semester.year.start,
        s.semester.year.end,
        s.semester.semester,
        s.name,
        s.credits,
        s.processWeight != null ? (s.processWeight! * 100).toInt() : '',
        s.processPoint ?? '',
        s.examPoint ?? '',
      ]);
    }

    final csvString = Csv().encoder.convert(rows);
    final bytes = utf8.encode(csvString);

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'unigpa_backup_${DateTime.now().millisecondsSinceEpoch}.csv',
        )
        ..click();

      html.Url.revokeObjectUrl(url);
    } else {
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Chọn nơi lưu dữ liệu sao lưu',
        fileName: 'unigpa_backup_${DateTime.now().millisecondsSinceEpoch}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
        bytes: bytes,
      );

      if (path != null && !Platform.isAndroid && !Platform.isIOS) {
        final file = File(path);
        await file.writeAsBytes(bytes);
      }
    }
  }

  static Future<List<Subject>?> importSubjects() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    try {
      final file = result.files.first;
      late final List<int> bytes;

      if (kIsWeb) {
        if (file.bytes == null) return null;
        bytes = file.bytes!;
      } else {
        if (file.path == null) return null;
        bytes = await File(file.path!).readAsBytes();
      }

      final csvString = utf8.decode(bytes);
      final List<List<dynamic>> rows = Csv().decoder.convert(csvString);

      if (rows.length < 2) return [];

      final List<Subject> subjects = [];

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 8) continue;

        try {
          final yearStart = int.parse(row[0].toString());
          final yearEnd = int.parse(row[1].toString());
          final semesterNum = int.parse(row[2].toString());
          final name = row[3].toString();
          final credits = int.parse(row[4].toString());
          final weight = double.tryParse(row[5].toString());
          final pScore = double.tryParse(row[6].toString());
          final eScore = double.tryParse(row[7].toString());

          subjects.add(
            Subject(
              name: name,
              credits: credits,
              semester: AcademicSemester(
                year: Year(yearStart, yearEnd),
                semester: semesterNum,
              ),
              processWeight: weight != null ? weight / 100 : null,
              processPoint: pScore,
              examPoint: eScore,
            ),
          );
        } catch (_) {
          continue;
        }
      }
      return subjects;
    } catch (e) {
      return [];
    }
  }
}
