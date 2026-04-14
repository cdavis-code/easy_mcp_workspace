// Simple todo model for the MCP example
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, this.completed = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as int,
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
  );

  @override
  String toString() => 'Todo(id: $id, title: $title, completed: $completed)';
}
