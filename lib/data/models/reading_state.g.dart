// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingStateAdapter extends TypeAdapter<ReadingState> {
  @override
  final int typeId = 3;

  @override
  ReadingState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingState(
      lastSubject: fields[0] as String?,
      lastChapterIndex: fields[1] as int?,
      scrollPosition: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingState obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lastSubject)
      ..writeByte(1)
      ..write(obj.lastChapterIndex)
      ..writeByte(2)
      ..write(obj.scrollPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
