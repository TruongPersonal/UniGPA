// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 2;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      name: fields[0] as String,
      credits: fields[1] as int,
      point10: fields[2] as double?,
      semester: fields[3] as AcademicSemester,
      processWeight: fields[4] as double?,
      processPoint: fields[5] as double?,
      examPoint: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.credits)
      ..writeByte(2)
      ..write(obj.point10)
      ..writeByte(3)
      ..write(obj.semester)
      ..writeByte(4)
      ..write(obj.processWeight)
      ..writeByte(5)
      ..write(obj.processPoint)
      ..writeByte(6)
      ..write(obj.examPoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
