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

The server uses `dart_mcp` with stdio transport. Each invocation starts a fresh server instance.

**Initialize the server:**

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
  | dart run example/lib/src/user.mcp.dart
```

Expected response:
```json
{"jsonrpc":"2.0","result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{"listChanged":true}},"serverInfo":{"name":"mcp-server","version":"1.0.0"},"instructions":"Auto-generated MCP server"},"id":1}
```

**Initialize and list tools:**

```bash
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}\n{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' \
  | dart run example/lib/src/user.mcp.dart
```

Expected response (two JSON lines):
```json
{"jsonrpc":"2.0","result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{"listChanged":true}},"serverInfo":{"name":"mcp-server","version":"1.0.0"},"instructions":"Auto-generated MCP server"},"id":1}
{"jsonrpc":"2.0","result":{"tools":[{"name":"createUser","description":"Create a new user","inputSchema":{"type":"object","properties":{"name":{"type":"string"},"email":{"type":"string"}}}},{"name":"getUser","description":"Get user by ID","inputSchema":{"type":"object","properties":{"id":{"type":"integer"}},"required":["id"]}},{"name":"listUsers","description":"List all users","inputSchema":{"type":"object"}},{"name":"deleteUser","description":"Delete a user","inputSchema":{"type":"object","properties":{"id":{"type":"integer"}},"required":["id"]}},{"name":"searchUsers","description":"Search users by query","inputSchema":{"type":"object","properties":{"query":{"type":"string"}},"required":["query"]}}]},"id":2}
```

> **Note:** Tool calls (`tools/call`) require the server to stay alive while async handlers complete. For testing tool calls, use an MCP client like Claude Desktop, the `mcp` CLI, or run the server interactively:
>
> ```bash
> dart run example/lib/src/user.mcp.dart
> # Then type JSON-RPC requests manually, one per line
> ```

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
import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

void main() {
  MCPServerWithTools(stdioChannel(input: io.stdin, output: io.stdout));
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
