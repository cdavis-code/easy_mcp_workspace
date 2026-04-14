# easy_mcp_annotations

<p align="center">
  <img src="../../images/logo-banner.svg" width="400" alt="easy_mcp">
</p>

Dart annotations for exposing library methods as MCP tools.

Provides the `@mcp` and `@tool` annotations used to define Model Context Protocol (MCP) servers and tools using Dart code that can be processed by the `easy_mcp_generator` build_runner package.

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  easy_mcp_annotations: ^0.1.3
```

## Usage

### Basic Example (stdio transport)

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

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

### HTTP Transport with Custom Port and Address

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@mcp(
  transport: McpTransport.http,
  port: 8080,
  address: '0.0.0.0',  // Use '0.0.0.0' to listen on all interfaces
)
class MyServer {
  @tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }
}
```

#### @Mcp Annotation Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `transport` | `McpTransport` | `McpTransport.stdio` | Transport protocol: `stdio` or `http` |
| `port` | `int` | `3000` | HTTP server port (only for HTTP transport) |
| `address` | `String` | `'127.0.0.1'` | HTTP bind address (only for HTTP transport). Use `'0.0.0.0'` to listen on all interfaces |
| `generateJson` | `bool` | `false` | Whether to generate `.mcp.json` metadata file |

See the [example](../../example) directory in the workspace root for a complete working example that demonstrates usage of both packages together.

## Features

- Simple annotations for defining MCP servers and tools
- Support for both stdio (JSON-RPC) and HTTP transports
- **Configurable HTTP server** - Customize port and bind address
- Compatible with `easy_mcp_generator` for automatic server code generation
- Null safety compatible (Dart 3.9+)

## License

BSD-3-Clause - See [LICENSE](LICENSE) for details.

## Support

If you find this package useful, consider supporting its development:

- [Buy me a coffee](https://buymeacoffee.com/cdavis)