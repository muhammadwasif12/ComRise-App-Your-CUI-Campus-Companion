class Note {
  final int? id;
  final String userId;
  final String content;
  final String type; // 'text' or 'image'
  final String? filePath;
  final DateTime createdAt;

  Note({
    this.id,
    required this.userId,
    required this.content,
    this.type = 'text',
    this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      content: map['content'] as String,
      type: map['type'] as String? ?? 'text',
      filePath: map['filePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
