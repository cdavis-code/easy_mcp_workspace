# MCP Example

<p align="center">
  <img src="../images/logo-banner.svg" width="400" alt="easy_mcp">
</p>

Example demonstrating how to use `easy_mcp_annotations` and `easy_mcp_generator`. This example showcases a realistic many-to-many domain model where **Users** and **Todos** have bidirectional relationships — a todo can be assigned to multiple users, and a user can have multiple todos.

## Prerequisites

This example is part of the `easy_mcp_workspace`. From the project root:

```bash
dart pub get
```

## Usage

### 1. Add annotations to your library

Use `@Mcp` on your entry point and `@Tool` on static methods you want to expose as MCP tools:

```dart
// bin/example.dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';
import 'package:mcp_example/src/user_store.dart';
import 'package:mcp_example/src/todo_store.dart';

@Mcp(transport: McpTransport.stdio)
Future<void> main() async {
  // Your initialization code...
}
```

#### HTTP Transport Configuration

For HTTP transport, you can customize the port and bind address:

```dart
@Mcp(
  transport: McpTransport.http,
  port: 8080,           // Default: 3000
  address: '0.0.0.0',   // Default: '127.0.0.1' (loopback)
)
Future<void> main() async {
  // Your initialization code...
}
```

**Note:** Use `address: '0.0.0.0'` to listen on all network interfaces (useful for Docker containers or remote access).

```dart
// lib/src/user_store.dart
class UserStore {
  @Tool(description: 'Create a new user')
  static Future<User> createUser({
    @Parameter(
      title: 'Full Name',
      description: 'The user\'s full name (1-100 characters)',
      example: 'John Doe',
    )
    required String name,
    @Parameter(
      title: 'Email Address',
      description: 'A valid email address for the user',
      example: 'john.doe@example.com',
      pattern: r'^[\w\.-]+@[\w\.-]+\.\w+$',
    )
    required String email,
  }) async { ... }

  @Tool(description: 'Get user by ID')
  static Future<User?> getUser(int id) async { ... }

  @Tool(description: 'Get all todos assigned to a user')
  static Future<List<Todo>> getUserTodos(int userId) async { ... }
}
```

#### Parameter Annotations (Optional)

The `@Parameter` annotation is **optional** and only needed when you want to provide additional metadata for parameters. By default, the generator extracts parameter information from Dart types and doc comments.

Use `@Parameter` when you need:
- Human-readable titles and descriptions
- Example values to guide users
- Validation constraints (min/max, patterns, enum values)
- To mark sensitive data (passwords, API keys)

**Without `@Parameter` (simpler approach):**
```dart
@Tool(description: 'Create a new user')
static Future<User> createUser({
  required String name,
  required String email,
}) async { ... }
```

**With `@Parameter` (rich metadata):**

```dart
@Tool(description: 'Create a new item')
static Future<Item> createItem({
  @Parameter(
    title: 'Item Name',
    description: 'A descriptive name for the item',
    example: 'My Awesome Item',
  )
  required String name,
  
  @Parameter(
    title: 'Quantity',
    description: 'Number of items (1-100)',
    minimum: 1,
    maximum: 100,
    example: 5,
  )
  int quantity = 1,
  
  @Parameter(
    title: 'Category',
    description: 'Item category',
    enumValues: ['electronics', 'clothing', 'food', 'other'],
    example: 'electronics',
  )
  String? category,
}) async { ... }
```

```dart
// lib/src/todo_store.dart
class TodoStore {
  @Tool(description: 'Create a new todo')
  static Future<Todo> createTodo({required String title}) async { ... }

  @Tool(description: 'Assign a todo to a user')
  static Future<Todo?> assignTodoToUser({required int todoId, required int userId}) async { ... }

  @Tool(description: 'Get all todos assigned to a user')
  static Future<List<Todo>> getTodosForUser(int userId) async { ... }
}
```

### 2. Run code generation

From the **project root** (not the example directory):

```bash
# Generate all .mcp.dart files
dart run build_runner build --delete-conflicting-outputs

# Or watch for changes
dart run build_runner build --delete-conflicting-outputs --watch
```

This generates:
- `bin/example.mcp.dart` — Generated MCP server using `dart_mcp` that aggregates all tools from imported libraries

The generator discovers all `@Tool`-annotated methods from libraries imported by the `@Mcp`-annotated entry point and registers them in a single MCP server.

## Available Tools

The generated MCP server exposes 14 tools organized by store:

### UserStore (6 tools)

| Tool | Description | Parameters |
|------|-------------|------------|
| `createUser` | Create a new user | `name` (String), `email` (String) |
| `getUser` | Get user by ID | `id` (int) |
| `listUsers` | List all users | none |
| `deleteUser` | Delete a user | `id` (int) |
| `searchUsers` | Search users by query | `query` (String) |
| `getUserTodos` | Get all todos assigned to a user | `userId` (int) |

### TodoStore (8 tools)

| Tool | Description | Parameters |
|------|-------------|------------|
| `createTodo` | Create a new todo | `title` (String) |
| `getTodo` | Get todo by ID | `id` (int) |
| `listTodos` | List all todos | none |
| `deleteTodo` | Delete a todo | `id` (int) |
| `completeTodo` | Mark a todo as completed | `id` (int) |
| `assignTodoToUser` | Assign a todo to a user | `todoId` (int), `userId` (int) |
| `removeTodoFromUser` | Remove a user from a todo | `todoId` (int), `userId` (int) |
| `getTodosForUser` | Get all todos assigned to a user | `userId` (int) |

## Annotations

### `@Mcp`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `transport` | `McpTransport` | `McpTransport.stdio` | Transport protocol (stdio or http) |
| `port` | `int` | `3000` | HTTP server port (only for HTTP transport) |
| `address` | `String` | `'127.0.0.1'` | HTTP bind address (only for HTTP transport). Use `'0.0.0.0'` to listen on all interfaces |

### `@Tool`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `description` | `String?` | auto-extract | Tool description (falls back to doc comment) |
| `icons` | `List<String>?` | `null` | Icon URLs |

## Running the Generated Server

After running `build_runner`, run the generated server:

```bash
dart run example/bin/example.mcp.dart
```

### stdio Transport (Default)

The server uses `dart_mcp` with stdio transport. It communicates via JSON-RPC 2.0 over stdin/stdout.

### HTTP Transport

If you configured HTTP transport with custom port/address (as shown in the example above with port 8080 and address '0.0.0.0'):

```bash
dart run example/bin/example.mcp.dart
# Server will listen on http://0.0.0.0:8080
```

With default settings (port 3000, address '127.0.0.1'):

```bash
dart run example/bin/example.mcp.dart
# Server will listen on http://127.0.0.1:3000
```

The HTTP server accepts POST requests with JSON-RPC 2.0 payloads.

### Testing the Server

Use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) — the official testing tool for MCP servers — to test all tools via CLI.

**Prerequisites:** Node.js 22.7.5+

**List available tools**

```bash
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/list
```

**Call tools**

```bash
# UserStore tools

# Call listUsers (no parameters)
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name listUsers

# Call createUser with parameters
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name createUser --tool-arg 'name=Test User' --tool-arg 'email=test@example.com'

# Call getUser with ID
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name getUser --tool-arg 'id=1'

# Call searchUsers with query
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name searchUsers --tool-arg 'query=Alice'

# Call getUserTodos
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name getUserTodos --tool-arg 'userId=1'

# TodoStore tools

# Call createTodo
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name createTodo --tool-arg 'title=Buy groceries'

# Call listTodos
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name listTodos

# Call completeTodo
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name completeTodo --tool-arg 'id=1'

# Call assignTodoToUser
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name assignTodoToUser --tool-arg 'todoId=1' --tool-arg 'userId=1'

# Call removeTodoFromUser
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name removeTodoFromUser --tool-arg 'todoId=1' --tool-arg 'userId=1'

# Call getTodosForUser
npx @modelcontextprotocol/inspector --cli dart run example/bin/example.mcp.dart --method tools/call --tool-name getTodosForUser --tool-arg 'userId=1'
```

**Alternative: Web UI mode**

For interactive browser-based testing, run without the `--cli` flag:

```bash
npx @modelcontextprotocol/inspector dart run example/bin/example.mcp.dart
```

Then open `http://localhost:6274` in your browser.

## Project Structure

```
example/
├── bin/
│   ├── example.dart          # Entry point with @Mcp annotation
│   └── example.mcp.dart      # Generated MCP server (aggregates all tools)
├── lib/
│   └── src/
│       ├── todo.dart          # Todo model
│       ├── todo_store.dart    # TodoStore with @Tool methods
│       ├── user.dart          # User model
│       └── user_store.dart    # UserStore with @Tool methods
├── build.yaml
└── pubspec.yaml
```

## Data Model

This example demonstrates a many-to-many relationship between Users and Todos:

- **User** has `todoIds: List<int>` — references to assigned todos
- **Todo** has `userIds: List<int>` — references to assigned users

The relationship is bidirectional and managed by the assignment tools:
- `assignTodoToUser()` — adds references in both directions
- `removeTodoFromUser()` — removes references from both directions
- `deleteUser()` — automatically cleans up todo references
- `deleteTodo()` — automatically cleans up user references

Data is persisted to JSON files (`users.json`, `todos.json`) in the example directory.

## Generated Code

The generated `.mcp.dart` file creates a complete MCP server using `dart_mcp`. It imports each store with a unique alias to avoid naming conflicts:

```dart
import 'package:mcp_example/src/user_store.dart' as user_store;
import 'package:mcp_example/src/todo_store.dart' as todo_store;

base class MCPServerWithTools extends MCPServer with ToolsSupport {
  MCPServerWithTools(super.channel)
    : super.fromStreamChannel(
        implementation: Implementation(
          name: 'mcp-server',
          version: '1.0.0',
        ),
        instructions: 'Auto-generated MCP server',
      ) {
    registerTool(
      Tool(
        name: 'createUser',
        description: 'Create a new user',
        inputSchema: Schema.object(
          properties: {
            'name': Schema.string(),
            'email': Schema.string(),
          },
          required: ['name', 'email'],
        ),
      ),
      _createUser,
    );
    registerTool(
      Tool(
        name: 'createTodo',
        description: 'Create a new todo',
        inputSchema: Schema.object(
          properties: {
            'title': Schema.string(),
          },
          required: ['title'],
        ),
      ),
      _createTodo,
    );
    registerTool(
      Tool(
        name: 'assignTodoToUser',
        description: 'Assign a todo to a user',
        inputSchema: Schema.object(
          properties: {
            'todoId': Schema.int(),
            'userId': Schema.int(),
          },
          required: ['todoId', 'userId'],
        ),
      ),
      _assignTodoToUser,
    );
    // ... more tools from both stores
  }

  FutureOr<CallToolResult> _createUser(CallToolRequest request) async {
    final name = request.arguments!['name'] as String;
    final email = request.arguments!['email'] as String;
    final result = await user_store.UserStore.createUser(name: name, email: email);
    return CallToolResult(content: [TextContent(text: _serializeResult(result))]);
  }

  FutureOr<CallToolResult> _createTodo(CallToolRequest request) async {
    final title = request.arguments!['title'] as String;
    final result = await todo_store.TodoStore.createTodo(title: title);
    return CallToolResult(content: [TextContent(text: _serializeResult(result))]);
  }

  // ... more handlers
}
```
