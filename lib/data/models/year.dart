import 'package:hive/hive.dart';

part 'year.g.dart';

@HiveType(typeId: 3)
class Year {
  @HiveField(0)
  int start;
  @HiveField(1)
  int end;

  Year(this.start, this.end);

  String get yearDisplay => '$start - $end';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Year && other.start == start;

  @override
  int get hashCode => start.hashCode;
}
