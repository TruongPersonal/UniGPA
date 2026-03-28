import 'package:hive/hive.dart';

part 'grade.g.dart';

@HiveType(typeId: 1)
class Grade extends HiveObject {
  @HiveField(0)
  String letter;
  @HiveField(1)
  double? point4;

  @HiveField(2)
  double? startPoint10;
  @HiveField(3)
  double? endPoint10;

  @HiveField(4)
  bool isActive;

  bool get isPassing => letter != 'F';

  Grade({
    required this.letter,
    this.point4,
    this.startPoint10,
    this.endPoint10,
    this.isActive = true,
  });
}
