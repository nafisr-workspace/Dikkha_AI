class Book {
  final String id;
  final String subject;
  final String grade;
  final String group;
  final String title;
  final List<Chapter> chapters;

  const Book({
    required this.id,
    required this.subject,
    required this.grade,
    required this.group,
    required this.title,
    required this.chapters,
  });
}

class Chapter {
  final String id;
  final int number;
  final String title;
  final String markdownPath;

  const Chapter({
    required this.id,
    required this.number,
    required this.title,
    required this.markdownPath,
  });
}

