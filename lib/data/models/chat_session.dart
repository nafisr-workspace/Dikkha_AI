import 'package:hive/hive.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 1)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final String? title;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.userId,
    required this.subject,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSession copyWith({
    String? id,
    String? userId,
    String? subject,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

