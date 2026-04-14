# mcp_annotations

Dart annotations for exposing library methods as MCP tools.

Provides the `@mcp` and `@tool` annotations used to define Model Context Protocol (MCP) servers and tools using Dart code that can be processed by the `mcp_generator` build_runner package.

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  mcp_annotations: ^0.1.0
```

## Usage

```dart
import 'package:mcp_annotations/mcp_annotations.dart';

@mcp(transport: McpTransport.stdio)
class MyServer {
  @tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }

  @tool(description: 'Get user by ID')
  Future<User?> getUser(int id) async {
    // Implementation here
    return null;
  }
}
```

See the [example](./example) directory for a complete working example.

## Features

- Simple annotations for defining MCP servers and tools
- Support for both stdio (JSON-RPC) and HTTP transports
- Compatible with `mcp_generator` for automatic server code generation
- Null safety compatible (Dart 3.9+)

## License

BSD-3-Clause - See [LICENSE](LICENSE) for details.

## Support

If you find this package useful, consider supporting its development:

- [Buy me a coffee](https://buymeacoffee.com/cdavis)