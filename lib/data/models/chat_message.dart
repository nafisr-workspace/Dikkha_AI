import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String role; // 'user' or 'ai'

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAi => role == 'ai';

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

