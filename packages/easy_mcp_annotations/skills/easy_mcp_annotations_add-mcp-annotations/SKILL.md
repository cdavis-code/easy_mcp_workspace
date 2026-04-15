---
name: easy_mcp_annotations_add-mcp-annotations
description: Add easy_mcp annotations (@Mcp, @Tool, @Parameter) to existing Dart code to expose methods as MCP tools. Use when converting Dart libraries to MCP servers, adding tool exposure to existing functions, or when the user wants to make their Dart code callable via the Model Context Protocol.
---

# Add MCP Annotations to Dart Code

Convert existing Dart methods into MCP tools using easy_mcp annotations.

## Overview

This skill helps you add `@Mcp`, `@Tool`, and `@Parameter` annotations to existing Dart code, transforming it into an MCP server that can be called by AI assistants and other MCP clients.

## Prerequisites

Before adding annotations:
1. Add `easy_mcp_annotations` to dependencies
2. Add `easy_mcp_generator` and `build_runner` to dev_dependencies
3. Run `dart pub get`

## Annotation Quick Reference

### @Mcp
Marks the entry point for MCP server generation.

```dart
@Mcp(
  transport: McpTransport.stdio,  // or McpTransport.http
  port: 3000,                      // for HTTP transport
  address: '127.0.0.1',           // for HTTP transport
  generateJson: false,            // generate .mcp.json file
)
```

**Parameters:**
- `transport`: `McpTransport.stdio` (default) or `McpTransport.http`
- `port`: HTTP server port (default: 3000)
- `address`: HTTP bind address (default: '127.0.0.1', use '0.0.0.0' for all interfaces)
- `generateJson`: Whether to generate JSON metadata file
- `toolPrefix`: Prefix added to all tool names (e.g., 'user_' makes 'createUser' → 'user_createUser')

### @Tool
Marks a method as an MCP tool.

```dart
@Tool(
  name: 'user_create',  // Custom tool name (optional, defaults to method name)
  description: 'Creates a new user in the system',
  icons: ['https://example.com/icon.png'],
)
```

**Parameters:**
- `name`: Optional custom tool name (defaults to method name). Useful for avoiding naming collisions
- `description`: Human-readable description (uses dartdoc if omitted)
- `icons`: Optional list of icon URLs for UI clients

### @Parameter (Optional)
Provides rich metadata for individual parameters.

```dart
@Parameter(
  title: 'Email Address',
  description: 'A valid email address',
  example: 'user@example.com',
  pattern: r'^[\w\.-]+@[\w\.-]+\.\w+$',
)
```

**Parameters:**
- `title`: Human-readable parameter name
- `description`: Detailed explanation
- `example`: Example value for guidance
- `minimum`/`maximum`: Numeric validation bounds
- `pattern`: Regex pattern for string validation
- `sensitive`: Mark as sensitive (passwords, API keys)
- `enumValues`: List of allowed values

## Workflow

### Step 1: Identify Methods to Expose

Look for methods that:
- Are `public` (not private with `_` prefix)
- Return `Future<T>` or simple types
- Have serializable parameters (primitives, lists, maps)
- Perform useful operations (CRUD, calculations, API calls)

### Step 2: Choose Transport Mode

**Use stdio when:**
- Integrating with CLI tools
- Running as a subprocess
- Local development and testing

**Use HTTP when:**
- Remote access needed
- Docker/containerized deployment
- Multiple clients need access

### Step 3: Add @Mcp Annotation

Place `@Mcp` on the class or library containing your tools:

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@Mcp(transport: McpTransport.stdio)
class UserService {
  // tools go here
}
```

### Step 4: Add @Tool Annotations

Mark each method you want to expose:

```dart
@Mcp(transport: McpTransport.stdio)
class UserService {
  @Tool(description: 'Get user by ID')
  Future<User?> getUser(int id) async {
    // existing implementation
  }
  
  @Tool(description: 'Create a new user')
  Future<User> createUser(String name, String email) async {
    // existing implementation
  }
}
```

### Step 5: Customize Tool Names (Optional)

By default, tool names match method names. Customize them to avoid collisions:

**Option A: Use `name` parameter on individual tools:**

```dart
@Mcp(transport: McpTransport.stdio)
class UserService {
  @Tool(
    name: 'user_create',  // Custom name instead of 'createUser'
    description: 'Creates a new user',
  )
  Future<User> createUser(String name, String email) async { ... }
}
```

**Option B: Use `toolPrefix` on the class (applies to all tools):**

```dart
@Mcp(transport: McpTransport.stdio, toolPrefix: 'user_service_')
class UserService {
  @Tool(description: 'Create user')
  Future<User> createUser() async { ... }  // Tool name: user_service_createUser
  
  @Tool(description: 'Delete user')
  Future<void> deleteUser(String id) async { ... }  // Tool name: user_service_deleteUser
}
```

### Step 6: Add @Parameter (Optional)

For parameters needing extra metadata:

```dart
@Tool(description: 'Search users')
Future<List<User>> searchUsers({
  @Parameter(
    title: 'Search Query',
    description: 'Name or email to search for',
    example: 'john@example.com',
  )
  required String query,
  
  @Parameter(
    title: 'Maximum Results',
    description: 'Limit number of results returned',
    minimum: 1,
    maximum: 100,
    example: 10,
  )
  int limit = 20,
}) async {
  // existing implementation
}
```

### Step 7: Generate Server Code

Run the build runner:

```bash
dart run build_runner build
```

This generates:
- `{file}.mcp.dart` - Complete MCP server implementation
- `{file}.mcp.json` (if `generateJson: true`) - Tool metadata

### Step 8: Run the Server

**For stdio transport:**
```bash
dart run bin/your_file.mcp.dart
```

**For HTTP transport:**
```bash
dart run bin/your_file.mcp.dart
# Server runs on configured port
```

## Common Patterns

### CRUD Service

```dart
@Mcp(transport: McpTransport.http, port: 8080)
class TodoService {
  @Tool(description: 'List all todos')
  Future<List<Todo>> listTodos() async { ... }
  
  @Tool(description: 'Get a todo by ID')
  Future<Todo?> getTodo(String id) async { ... }
  
  @Tool(description: 'Create a new todo')
  Future<Todo> createTodo({
    @Parameter(title: 'Title', example: 'Buy groceries')
    required String title,
    
    @Parameter(title: 'Priority', enumValues: ['low', 'medium', 'high'])
    String priority = 'medium',
  }) async { ... }
  
  @Tool(description: 'Update an existing todo')
  Future<Todo> updateTodo(String id, {String? title, bool? completed}) async { ... }
  
  @Tool(description: 'Delete a todo')
  Future<void> deleteTodo(String id) async { ... }
}
```

### API Client Wrapper

```dart
@Mcp(transport: McpTransport.stdio)
class WeatherApi {
  @Tool(description: 'Get current weather for a location')
  Future<Weather> getCurrentWeather({
    @Parameter(
      title: 'City Name',
      example: 'San Francisco',
      pattern: r'^[A-Za-z\s]+$',
    )
    required String city,
    
    @Parameter(
      title: 'Units',
      description: 'Temperature units',
      enumValues: ['celsius', 'fahrenheit'],
    )
    String units = 'celsius',
  }) async { ... }
}
```

### Utility Functions

```dart
@Mcp(transport: McpTransport.stdio)
class StringUtils {
  @Tool(description: 'Convert text to slug format')
  String toSlug(String text) { ... }
  
  @Tool(description: 'Count words in text')
  int countWords(String text) { ... }
  
  @Tool(description: 'Format date to readable string')
  String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) { ... }
}
```

## Best Practices

1. **Start Simple**: Begin with `@Mcp()` and `@Tool()` only, add `@Parameter` later if needed
2. **Use dartdoc**: Write good doc comments; they become tool descriptions automatically
3. **Validate Parameters**: Use `@Parameter` with `pattern`, `minimum`, `maximum` for validation
4. **Return Types**: Ensure return types are JSON-serializable
5. **Error Handling**: Throw descriptive exceptions; they become error messages in MCP clients

## Troubleshooting

**Build fails with "annotation not found"**
- Ensure `easy_mcp_annotations` is in `dependencies` (not dev_dependencies)
- Run `dart pub get`

**Generated code has errors**
- Check that all tool methods are public
- Ensure return types are not private classes
- Verify all parameters have serializable types

**HTTP server not accessible**
- Use `address: '0.0.0.0'` to listen on all interfaces
- Check firewall settings for the configured port

## Migration Checklist

When converting existing code:
- [ ] Add dependency on `easy_mcp_annotations`
- [ ] Add `@Mcp` to the main class/library
- [ ] Add `@Tool` to methods you want to expose
- [ ] Add `@Parameter` for complex parameter validation (optional)
- [ ] Run `dart run build_runner build`
- [ ] Test the generated server
- [ ] Update documentation
