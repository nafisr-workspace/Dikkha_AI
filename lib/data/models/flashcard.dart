import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 6)
class FlashcardSet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String sourceText;

  @HiveField(3)
  final List<Flashcard> cards;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int? masteredCount;

  FlashcardSet({
    required this.id,
    required this.subject,
    required this.sourceText,
    required this.cards,
    required this.createdAt,
    this.masteredCount,
  });

  FlashcardSet copyWith({
    String? id,
    String? subject,
    String? sourceText,
    List<Flashcard>? cards,
    DateTime? createdAt,
    int? masteredCount,
  }) {
    return FlashcardSet(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      sourceText: sourceText ?? this.sourceText,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      masteredCount: masteredCount ?? this.masteredCount,
    );
  }

  String get truncatedSourceText {
    if (sourceText.length <= 100) return sourceText;
    return '${sourceText.substring(0, 100)}...';
  }
}

@HiveType(typeId: 7)
class Flashcard {
  @HiveField(0)
  final String front;

  @HiveField(1)
  final String back;

  Flashcard({
    required this.front,
    required this.back,
  });

  Flashcard copyWith({
    String? front,
    String? back,
  }) {
    return Flashcard(
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}

