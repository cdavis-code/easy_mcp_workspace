# Quickstart: MCP Annotations

**Phase**: 1 | **Date**: 2026-04-12 | **Branch**: `001-mcp-annotations`

## Installation

```bash
# Add to your pubspec.yaml
dependencies:
  mcp_annotations: ^0.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.6
  mcp_generator:
    path: ../packages/mcp_generator
```

## Quick Usage

### 1. Define Your Tools

```dart
import 'package:mcp_annotations/mcp_annotations.dart';

@mcp(transport: McpTransport.stdio)
@tool(description: 'Create a new user')
Future<User> createUser(String name, String email) async {
  // Your implementation
  return User(name: name, email: email);
}

@tool(description: 'Get user by ID')
Future<User?> getUser(int id) async {
  // Your implementation
  return null;
}
```

### 2. Run Code Generation

```bash
dart run build_runner build
```

This generates `lib/src/users.mcp.dart` with:
- JSON-RPC request handler
- Tool registration map
- Stdio main() entry point

### 3. Run the Server

```bash
dart lib/src/users.mcp.dart
```

## CLI Usage

### Stdio Mode (Default)

```bash
# Run as stdio server
dart lib/src/tools.mcp.dart
```

### HTTP Mode

```dart
import 'package:mcp_annotations/mcp_annotations.dart';

@mcp(transport: McpTransport.http)
@tool(description: 'API endpoint')
String hello(String name) => 'Hello, $name';
```

## Configuration

### @mcp Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `transport` | `McpTransport` | `stdio` | Communication transport |

### @tool Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `description` | `String?` | auto-extract | Tool description |
| `icons` | `List<String>?` | null | HTTPS icon URLs |

## Doc Comments

Doc comments are automatically extracted:

```dart
/// Creates a new user with the given name and email.
///
/// ## Parameters
/// - `name`: The user's full name
/// - `email`: The user's email address
@tool
Future<User> createUser(String name, String email) async { ... }
```

The description becomes: "Creates a new user with the given name and email. Parameters - name: The user's full name - email: The user's email address"

## Next Steps

- See [data-model.md](./data-model.md) for schema details
- See [contracts/](./contracts/tool-schema.json) for JSON-Schema
- Run tests: `dart test packages/mcp_annotations/test/`