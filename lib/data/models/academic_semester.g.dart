part of 'academic_semester.dart';

class AcademicSemesterAdapter extends TypeAdapter<AcademicSemester> {
  @override
  final int typeId = 0;

  @override
  AcademicSemester read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AcademicSemester(
      year: fields[0] as Year,
      semester: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AcademicSemester obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicSemesterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
