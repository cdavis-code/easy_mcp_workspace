# MCP Example

Example demonstrating how to use `mcp_annotations` and `mcp_generator` with the official `dart_mcp` package.

## Prerequisites

This example is part of the `easy_mcp` workspace. From the project root:

```bash
dart pub get
```

## Usage

### 1. Add annotations to your library

Use `@Tool()` on library methods you want to expose as MCP tools:

```dart
import 'package:mcp_annotations/mcp_annotations.dart';

class MyTools {
  @Tool(description: 'Create a new user')
  Future<User> createUser(String name, String email) async { ... }

  @Tool(description: 'Get user by ID')
  Future<User?> getUser(int id) async { ... }
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
- `lib/src/user.mcp.dart` — Generated MCP server using `dart_mcp`

### Available Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `createUser` | Create a new user | `name` (String), `email` (String) |
| `getUser` | Get user by ID | `id` (int) |
| `listUsers` | List all users | none |
| `deleteUser` | Delete a user | `id` (int) |
| `searchUsers` | Search users by query | `query` (String) |

## Annotations

### `@Tool`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `description` | `String?` | auto-extract | Tool description (falls back to doc comment) |
| `icons` | `List<String>?` | `null` | Icon URLs |

## Running the Generated Server

After running `build_runner`, run the generated server:

```bash
dart run example/lib/src/user.mcp.dart
```

The server uses `dart_mcp` with stdio transport. It communicates via JSON-RPC 2.0 over stdin/stdout.

### Testing the Server

Use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) — the official testing tool for MCP servers — to test all tools via CLI.

**Prerequisites:** Node.js 22.7.5+

**List available tools**

```bash
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/list
```

**Call a tool**

```bash
# Call listUsers (no parameters)
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/call --tool-name listUsers

# Call createUser with parameters
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/call --tool-name createUser --tool-arg 'name=Test User' --tool-arg 'email=test@example.com'

# Call getUser with ID
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/call --tool-name getUser --tool-arg 'id=1'

# Call searchUsers with query
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/call --tool-name searchUsers --tool-arg 'query=Alice'

# Call deleteUser
npx @modelcontextprotocol/inspector --cli dart run example/lib/src/user.mcp.dart --method tools/call --tool-name deleteUser --tool-arg 'id=1'
```

**Available tools:**

| Tool | Description | Parameters |
|------|-------------|------------|
| `createUser` | Create a new user | `name` (String), `email` (String) |
| `getUser` | Get user by ID | `id` (int) |
| `listUsers` | List all users | none |
| `deleteUser` | Delete a user | `id` (int) |
| `searchUsers` | Search users by query | `query` (String) |

**Alternative: Web UI mode**

For interactive browser-based testing, run without the `--cli` flag:

```bash
npx @modelcontextprotocol/inspector dart run example/lib/src/user.mcp.dart
```

Then open `http://localhost:6274` in your browser.

## Project Structure

```
example/
├── bin/
│   └── example.dart         # Example with @Mcp annotation
├── lib/
│   └── src/
│       ├── user.dart        # Annotated source with UserStore
│       └── user.mcp.dart    # Generated MCP server (dart_mcp)
├── build.yaml                # Build runner configuration
└── pubspec.yaml
```

## Generated Code

The generated `.mcp.dart` file creates a complete MCP server using `dart_mcp`:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

Future<void> main() async {
  final server = MCPServerWithTools(
    stdioChannel(input: io.stdin, output: io.stdout),
  );
  await server.done;
}

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
        ),
      ),
      _createUser,
    );
    // ... more tools
  }
}
```
