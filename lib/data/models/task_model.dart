class TaskModel {
  final String id;
  final String title;
  final bool completed;
  final int? createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.completed = false,
    this.createdAt,
  });

  factory TaskModel.fromJson(String id, Map<String, dynamic> json) {
    return TaskModel(
      id: id,
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      createdAt: json['createdAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': completed,
        'createdAt':
            createdAt ?? DateTime.now().millisecondsSinceEpoch,
      };

  TaskModel copyWith({
    String? id,
    String? title,
    bool? completed,
    int? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}