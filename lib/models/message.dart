class Message {
  const Message({
    this.id,
    required this.content,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message copyWith({
    int? id,
    String? content,
    String? imagePath,
    bool clearImage = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'content': content,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, Object?> map) {
    return Message(
      id: map['id'] as int?,
      content: map['content'] as String,
      imagePath: map['image_path'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
