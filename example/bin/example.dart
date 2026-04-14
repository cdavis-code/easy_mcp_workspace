// Example: Using mcp_annotations to expose library methods as MCP tools
import 'package:mcp_annotations/mcp_annotations.dart';
import 'package:mcp_example/src/user_store.dart';
import 'package:mcp_example/src/todo.dart';

@Mcp(transport: McpTransport.stdio)
Future<void> main() async {
  // Seed some initial users if the store is empty
  final existing = await UserStore.listUsers();
  if (existing.isEmpty) {
    print('Seeding initial users...');
    await UserStore.createUser(
      name: 'Alice Smith',
      email: 'alice@example.com',
      todos: [
        Todo(id: 1, title: 'Buy groceries'),
        Todo(id: 2, title: 'Walk the dog', completed: true),
      ],
    );
    await UserStore.createUser(
      name: 'Bob Jones',
      email: 'bob@example.com',
      todos: [Todo(id: 3, title: 'Finish project')],
    );
    await UserStore.createUser(
      name: 'Charlie Brown',
      email: 'charlie@example.com',
      todos: [],
    );
  }

  // Show all users
  final allUsers = await UserStore.listUsers();
  print('All users (${allUsers.length}):');
  for (final user in allUsers) {
    print('  $user');
    for (final todo in user.todos) {
      print('    - $todo');
    }
  }
}
