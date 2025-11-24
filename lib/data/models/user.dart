import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String grade;

  @HiveField(4)
  final String group;

  @HiveField(5)
  final String board;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  @HiveField(8)
  final String? profilePicPath;

  User({
    required this.id,
    required this.phone,
    required this.name,
    required this.grade,
    required this.group,
    required this.board,
    required this.createdAt,
    this.updatedAt,
    this.profilePicPath,
  });

  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? grade,
    String? group,
    String? board,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePicPath,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      group: group ?? this.group,
      board: board ?? this.board,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePicPath: profilePicPath ?? this.profilePicPath,
    );
  }
}

