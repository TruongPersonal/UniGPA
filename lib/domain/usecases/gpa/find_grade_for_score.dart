import 'package:unigpa/data/models/grade.dart';

class FindGradeForScore {

  Grade? call({required double? point10, required List<Grade> grades}) {
    if (point10 == null) return null;
    try {
      return grades.firstWhere(
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
