// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardSetAdapter extends TypeAdapter<FlashcardSet> {
  @override
  final int typeId = 6;

  @override
  FlashcardSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardSet(
      id: fields[0] as String,
      subject: fields[1] as String,
      sourceText: fields[2] as String,
      cards: (fields[3] as List).cast<Flashcard>(),
      createdAt: fields[4] as DateTime,
      masteredCount: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardSet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.sourceText)
      ..writeByte(3)
      ..write(obj.cards)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.masteredCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 7;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      front: fields[0] as String,
      back: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.front)
      ..writeByte(1)
      ..write(obj.back);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
