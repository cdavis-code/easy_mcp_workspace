// Simple user model for the MCP example
import 'todo.dart';

class User {
  final int id;
  final String name;
  final String email;
  final List<Todo> todos;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.todos = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'todos': todos.map((t) => t.toJson()).toList(),
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final todosJson = json['todos'] as List<dynamic>?;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      todos:
          todosJson
              ?.map((e) => Todo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, todos: ${todos.length})';
}
