// Persistent user store backed by a JSON file.
import 'dart:convert';
import 'dart:io';
import 'package:mcp_annotations/mcp_annotations.dart';
import 'user.dart';
import 'todo.dart';

class UserStore {
  static const _filePath = 'users.json';
  static List<User>? _cache;

  static Future<List<User>> _loadUsers() async {
    if (_cache != null) return _cache!;

    final file = File(_filePath);
    if (!await file.exists()) {
      _cache = [];
      return _cache!;
    }

    final content = await file.readAsString();
    if (content.isEmpty) {
      _cache = [];
      return _cache!;
    }

    final json = jsonDecode(content) as List;
    _cache = json.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  static Future<void> _saveUsers(List<User> users) async {
    _cache = users;
    final file = File(_filePath);
    final json = jsonEncode(users.map((u) => u.toJson()).toList());
    await file.writeAsString(json);
  }

  static int get _nextId {
    if (_cache == null || _cache!.isEmpty) return 1;
    return _cache!.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Creates a new user with the given name and email.
  ///
  /// ## Parameters
  /// - `name` - The user's full name (1-100 characters)
  /// - `email` - The user's email address
  @Tool(description: 'Create a new user')
  static Future<User> createUser({
    required String name,
    required String email,
    List<Todo>? todos,
  }) async {
    final users = await _loadUsers();
    final user = User(
      id: _nextId,
      name: name,
      email: email,
      todos: todos ?? [],
    );
    users.add(user);
    await _saveUsers(users);
    return user;
  }

  /// Gets a user by their ID.
  @Tool(description: 'Get user by ID')
  static Future<User?> getUser(int id) async {
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Lists all users in the store.
  @Tool(description: 'List all users')
  static Future<List<User>> listUsers() async {
    return _loadUsers();
  }

  /// Deletes a user by their ID.
  @Tool(description: 'Delete a user')
  static Future<bool> deleteUser(int id) async {
    final users = await _loadUsers();
    final initialLength = users.length;
    users.removeWhere((u) => u.id == id);
    if (users.length != initialLength) {
      await _saveUsers(users);
      return true;
    }
    return false;
  }

  /// Search users by query string.
  @Tool(description: 'Search users by query')
  static Future<List<User>> searchUsers(String query) async {
    final users = await _loadUsers();
    final lowerQuery = query.toLowerCase();
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(lowerQuery) ||
              u.email.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
