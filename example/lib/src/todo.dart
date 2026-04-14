class Todo {
  final int id;
  final String title;
  final bool completed;
  final List<int> userIds;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    this.userIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    'userIds': userIds,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as int,
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
    userIds:
        (json['userIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        [],
  );

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    List<int>? userIds,
  }) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    userIds: userIds ?? this.userIds,
  );

  @override
  String toString() =>
      'Todo(id: $id, title: $title, completed: $completed, userIds: $userIds)';
}
