import 'package:hive/hive.dart';

part 'quiz.g.dart';

@HiveType(typeId: 4)
class Quiz extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String sourceText;

  @HiveField(3)
  final List<QuizQuestion> questions;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int? lastScore;

  @HiveField(6)
  final int? totalAttempts;

  Quiz({
    required this.id,
    required this.subject,
    required this.sourceText,
    required this.questions,
    required this.createdAt,
    this.lastScore,
    this.totalAttempts,
  });

  Quiz copyWith({
    String? id,
    String? subject,
    String? sourceText,
    List<QuizQuestion>? questions,
    DateTime? createdAt,
    int? lastScore,
    int? totalAttempts,
  }) {
    return Quiz(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      sourceText: sourceText ?? this.sourceText,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      lastScore: lastScore ?? this.lastScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }

  String get truncatedSourceText {
    if (sourceText.length <= 100) return sourceText;
    return '${sourceText.substring(0, 100)}...';
  }
}

@HiveType(typeId: 5)
class QuizQuestion {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final List<String> options;

  @HiveField(2)
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    int? correctIndex,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

