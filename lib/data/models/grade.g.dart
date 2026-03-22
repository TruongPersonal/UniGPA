part of 'grade.dart';

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 1;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      letter: fields[0] as String,
      point4: fields[1] as double?,
      startPoint10: fields[2] as double?,
      endPoint10: fields[3] as double?,
      isActive: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.letter)
      ..writeByte(1)
      ..write(obj.point4)
      ..writeByte(2)
      ..write(obj.startPoint10)
      ..writeByte(3)
      ..write(obj.endPoint10)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
