# easy_mcp_generator

<p align="center">
  <img src="../../images/logo-banner.svg" width="400" alt="easy_mcp">
</p>

Build Runner generator that creates MCP server code from @Tool annotations.

Processes Dart code annotated with `@Mcp` and `@Tool` from the `easy_mcp_annotations` package to generate complete MCP server implementations.

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  easy_mcp_generator: ^0.1.0
  easy_mcp_annotations: ^0.2.0

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

1. Annotate your functions with `@Mcp` and `@Tool`:

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@Mcp(transport: McpTransport.stdio)
class MyServer {
  @Tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }
}
```

### HTTP Transport Configuration

For HTTP transport, you can customize the port and bind address:

```dart
@Mcp(
  transport: McpTransport.http,
  port: 8080,           // Default: 3000
  address: '0.0.0.0',   // Default: '127.0.0.1' (loopback)
)
class MyServer {
  @Tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }
}
```

**Note:** Use `address: '0.0.0.0'` to listen on all network interfaces (useful for Docker containers or remote access).

### Parameter Annotations (Optional)

Use `@Parameter` to provide rich metadata for tool parameters:

```dart
@Mcp(transport: McpTransport.stdio)
class MyServer {
  @Tool(description: 'Create a new user')
  Future<bool> createUser({
    @Parameter(
      title: 'Full Name',
      description: 'The user\'s full name',
      example: 'John Doe',
    )
    required String name,
    
    @Parameter(
      title: 'Email Address',
      description: 'A valid email address',
      example: 'john@example.com',
      pattern: r'^[\w\.-]+@[\w\.-]+\.\w+$',
    )
    required String email,
    
    @Parameter(
      title: 'Age',
      description: 'User age in years',
      minimum: 0,
      maximum: 150,
      example: 25,
    )
    int? age,
  }) async {
    // Implementation here
    return true;
  }
}
```

The `@Parameter` annotation is **optional** - by default, the generator extracts parameter information from Dart types and method signatures. Use it when you need:
- Human-readable titles and descriptions
- Example values to guide users
- Validation constraints (min/max, patterns, enum values)
- To mark sensitive data (passwords, API keys)

2. Run the generator:

```bash
dart run build_runner build
```

This generates:
- `my_server.mcp.dart` - Complete MCP server (stdio or HTTP)

**Optional:** To also generate a `.mcp.json` metadata file, set `generateJson: true` in the `@Mcp` annotation:

```dart
@Mcp(
  transport: McpTransport.stdio,
  generateJson: true,  // Generates my_server.mcp.json
)
class MyServer { ... }
```

## Features

- **AST-based parsing** - Uses `dart:analyzer` for reliable annotation detection
- **Two transport modes** - stdio (JSON-RPC) and HTTP (Shelf-based) servers
- **Configurable HTTP server** - Customize port and bind address via `@Mcp` annotation
- **Automatic JSON-Schema generation** - Maps Dart types to proper JSON Schema
- **Rich parameter metadata** - Use `@Parameter` annotation for titles, descriptions, validation
- **Optional parameter support** - Handles named and optional positional parameters
- **Doc comment extraction** - Uses function doc comments when `@Tool.description` not provided
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