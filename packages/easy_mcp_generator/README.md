# easy_mcp_generator

<p align="center">
  <img src="../../logo-icon.svg" width="80" height="80" alt="easy_mcp logo">
</p>

Build Runner generator that creates MCP server code from @tool annotations.

Processes Dart code annotated with `@mcp` and `@tool` from the `easy_mcp_annotations` package to generate complete MCP server implementations.

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  easy_mcp_generator: ^0.1.0
  easy_mcp_annotations: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

1. Annotate your functions with `@mcp` and `@tool`:

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@mcp(transport: McpTransport.stdio)
class MyServer {
  @tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }
}
```

### HTTP Transport Configuration

For HTTP transport, you can customize the port and bind address:

```dart
@mcp(
  transport: McpTransport.http,
  port: 8080,           // Default: 3000
  address: '0.0.0.0',   // Default: '127.0.0.1' (loopback)
)
class MyServer {
  @tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }
}
```

**Note:** Use `address: '0.0.0.0'` to listen on all network interfaces (useful for Docker containers or remote access).

2. Add a `build.yaml` to your project:

```yaml
targets:
  $default:
    builders:
      easy_mcp_generator|mcpBuilder:
        enabled: true
```

3. Run the generator:

```bash
dart run build_runner build
```

This generates:
- `my_server.mcp.dart` - Complete MCP server (stdio or HTTP)
- `my_server.mcp.json` - Tool metadata with JSON-Schema definitions

## Features

- **AST-based parsing** - Uses `dart:analyzer` for reliable annotation detection
- **Two transport modes** - stdio (JSON-RPC) and HTTP (Shelf-based) servers
- **Configurable HTTP server** - Customize port and bind address via `@mcp` annotation
- **Automatic JSON-Schema generation** - Maps Dart types to proper JSON Schema
- **Optional parameter support** - Handles named and optional positional parameters
- **Doc comment extraction** - Uses function doc comments when `@tool.description` not provided
- **Dynamic method dispatch** - Generated `_dispatch` function routes to actual tool methods

## Example

See the [example](../../example) directory in the workspace root for a complete working example that demonstrates usage of both packages together.

## Generated Server Capabilities

The generated MCP server supports:
- `initialize` - Standard MCP initialization
- `tools/list` - Returns list of available tools with schemas
- `tools/call` - Executes the requested tool with provided arguments

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

If you find this package useful, consider supporting its development:

- [Buy me a coffee](https://buymeacoffee.com/cdavis)