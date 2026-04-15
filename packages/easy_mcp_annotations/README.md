# easy_mcp_annotations

<p align="center">
  <img src="../../images/logo-banner.svg" width="400" alt="easy_mcp">
</p>

Dart annotations for exposing library methods as MCP tools.

Provides the `@Mcp` and `@Tool` annotations used to define Model Context Protocol (MCP) servers and tools using Dart code that can be processed by the `easy_mcp_generator` build_runner package.

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  easy_mcp_annotations: ^0.4.1
```

## Usage

### Basic Example (stdio transport)

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@Mcp(transport: McpTransport.stdio)
class MyServer {
  @Tool(description: 'Create a new user')
  Future<bool> createUser(String name, String email) async {
    // Implementation here
    return true;
  }

  @Tool(description: 'Get user by ID')
  Future<User?> getUser(int id) async {
    // Implementation here
    return null;
  }
}
```

### HTTP Transport with Custom Port and Address

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@Mcp(
  transport: McpTransport.http,
  port: 8080,
  address: '0.0.0.0',  // Use '0.0.0.0' to listen on all interfaces
)
class MyServer {
  @Tool(description: 'Create a new user')
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
| `toolPrefix` | `String?` | `null` | Prefix added to all tool names (e.g., `'user_'` makes `createUser` → `user_createUser`) |
| `autoClassPrefix` | `bool` | `false` | Automatically prefix tool names with class name (e.g., `UserService_createUser`) |

### Parameter Annotations (Optional)

The `@Parameter` annotation is **optional**. By default, the generator automatically extracts parameter information from Dart types and method signatures. You only need `@Parameter` when you want to provide additional metadata beyond what's available from the code itself.

Use `@Parameter` to provide rich metadata for individual tool parameters:

```dart
@Tool(description: 'Create a new user')
Future<User> createUser({
  @Parameter(
    title: 'Full Name',
    description: 'The user\'s complete name',
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
}) async { ... }
```

#### @Parameter Annotation Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String?` | `null` | Human-readable title for the parameter |
| `description` | `String?` | `null` | Detailed description of the parameter |
| `example` | `Object?` | `null` | Example value to guide users |
| `minimum` | `num?` | `null` | Minimum value for numeric parameters |
| `maximum` | `num?` | `null` | Maximum value for numeric parameters |
| `pattern` | `String?` | `null` | Regular expression pattern for string validation |
| `sensitive` | `bool` | `false` | Whether this parameter contains sensitive data |
| `enumValues` | `List<Object?>?` | `null` | List of allowed values |

#### @Tool Annotation Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `String?` | `null` | Custom tool name (defaults to method name). Useful for avoiding naming collisions |
| `description` | `String?` | `null` | Tool description (uses dartdoc if omitted) |
| `icons` | `List<String>?` | `null` | List of icon URLs for UI clients |

**Example with custom tool name:**

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

**Example with tool prefix:**

```dart
@Mcp(transport: McpTransport.stdio, toolPrefix: 'user_service_')
class UserService {
  @Tool(description: 'Create user')
  Future<User> createUser() async { ... }  // Tool name: user_service_createUser
  
  @Tool(description: 'Delete user')
  Future<void> deleteUser(String id) async { ... }  // Tool name: user_service_deleteUser
}
```

**Example with auto class prefix:**

```dart
@Mcp(transport: McpTransport.stdio, autoClassPrefix: true)
class UserService {
  @Tool(description: 'Create user')
  Future<User> createUser() async { ... }  // Tool name: UserService_createUser
  
  @Tool(description: 'Delete user')
  Future<void> deleteUser(String id) async { ... }  // Tool name: UserService_deleteUser
}
```

**Combining autoClassPrefix with toolPrefix:**

```dart
@Mcp(transport: McpTransport.stdio, autoClassPrefix: true, toolPrefix: 'api_')
class UserService {
  @Tool(description: 'Create user')
  Future<User> createUser() async { ... }  // Tool name: api_UserService_createUser
}
```

See the [example](https://github.com/cdavis-code/easy_mcp_workspace/tree/main/example) directory in the workspace root for a complete working example that demonstrates usage of both packages together.

## Features

- Simple annotations for defining MCP servers and tools
- Support for both stdio (JSON-RPC) and HTTP transports
- **Configurable HTTP server** - Customize port and bind address
- **Rich parameter metadata** - Use `@Parameter` for titles, descriptions, examples, validation
- Compatible with `easy_mcp_generator` for automatic server code generation
- Null safety compatible (Dart 3.9+)

## License

BSD-3-Clause - See [LICENSE](LICENSE) for details.

## Support

If you find this package useful, consider supporting its development:

- [Buy me a coffee](https://buymeacoffee.com/cdavis)