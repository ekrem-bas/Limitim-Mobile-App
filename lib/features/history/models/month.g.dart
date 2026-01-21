// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthAdapter extends TypeAdapter<Month> {
  @override
  final int typeId = 1;

  @override
  Month read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Month(
      id: fields[0] as String,
      name: fields[1] as String,
      limit: fields[2] as double,
      isDraft: fields[3] as bool,
      year: fields[4] as int?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Month obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.limit)
      ..writeByte(3)
      ..write(obj.isDraft)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
