import 'package:hive/hive.dart';

part 'reading_state.g.dart';

@HiveType(typeId: 3)
class ReadingState extends HiveObject {
  @HiveField(0)
  final String? lastSubject;

  @HiveField(1)
  final int? lastChapterIndex;

  @HiveField(2)
  final double? scrollPosition;

  ReadingState({
    this.lastSubject,
    this.lastChapterIndex,
    this.scrollPosition,
  });

  ReadingState copyWith({
    String? lastSubject,
    int? lastChapterIndex,
    double? scrollPosition,
  }) {
    return ReadingState(
      lastSubject: lastSubject ?? this.lastSubject,
      lastChapterIndex: lastChapterIndex ?? this.lastChapterIndex,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }
}

