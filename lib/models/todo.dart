class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

