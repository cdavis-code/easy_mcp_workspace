class User {
  final int id;
  final String name;
  final String email;
  final List<int> todoIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.todoIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'todoIds': todoIds,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    todoIds:
        (json['todoIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        [],
  );

  User copyWith({int? id, String? name, String? email, List<int>? todoIds}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        todoIds: todoIds ?? this.todoIds,
      );

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, todoIds: $todoIds)';
}
