<p align="center">
  <img src="images/logo-banner.svg" width="600" alt="easy_mcp">
</p>

<p align="center">
  <strong>A Dart code generator that transforms annotated functions into Model Context Protocol (MCP) servers.</strong>
</p>

## Overview

Easy MCP allows you to expose Dart library functions as MCP tools using simple annotations. The generator produces ready-to-run stdio or HTTP servers that comply with the MCP specification.

## Packages

| Package | Description | Version |
|---------|-------------|---------|
| [`easy_mcp_annotations`](packages/easy_mcp_annotations) | Annotation definitions (`@Mcp`, `@Tool`, `@Parameter`) | [![pub package](https://img.shields.io/pub/v/easy_mcp_annotations.svg)](https://pub.dev/packages/easy_mcp_annotations) |
| [`easy_mcp_generator`](packages/easy_mcp_generator) | Build runner generator that produces MCP server code | [![pub package](https://img.shields.io/pub/v/easy_mcp_generator.svg)](https://pub.dev/packages/easy_mcp_generator) |

## Quick Start

### 1. Add Dependencies

```yaml
dependencies:
  easy_mcp_annotations: ^0.2.0

dev_dependencies:
  build_runner: ^2.4.0
  easy_mcp_generator: ^0.2.0
```

### 2. Annotate Your Functions

```dart
import 'package:easy_mcp_annotations/mcp_annotations.dart';

@Mcp(transport: McpTransport.stdio)
class UserServer {
  @Tool(description: 'Get user by ID')
  Future<User> getUser(int id) async {
    // ...
  }
}
```

### 3. Run the Generator

```bash
dart run build_runner build
```

### 4. Run the Server

```bash
dart run lib/my_server.mcp.dart
```

## Annotations

### `@Mcp`

Controls the transport type and configuration for the generated server.

```dart
// Stdio transport (default)
@Mcp(transport: McpTransport.stdio)

// HTTP transport with custom port and address
@Mcp(
  transport: McpTransport.http,
  port: 8080,                    // Default: 3000
  address: '0.0.0.0',            // Default: '127.0.0.1'
  generateJson: true,            // Optional: generate .mcp.json metadata
)
```

### `@Tool`

Marks a method as an MCP tool and provides metadata.

```dart
@Tool(description: 'Create a new user')
Future<User> createUser(String name, String email) async { ... }
```

If `description` is omitted, the function's doc comment is used.

### `@Parameter` (Optional)

Provides rich metadata for individual parameters. Use when you need custom titles, descriptions, examples, or validation constraints.

```dart
@Tool(description: 'Create a new user')
Future<User> createUser({
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
    minimum: 0,
    maximum: 150,
    example: 25,
  )
  int? age,
}) async { ... }
```

**Note:** `@Parameter` is optional. By default, the generator extracts parameter information from Dart types and method signatures.

## Features

- **AST-based parsing** - Uses `dart:analyzer` for reliable code extraction
- **Two transport modes** - stdio (JSON-RPC) and HTTP (Shelf-based)
- **Configurable HTTP server** - Customize port and bind address
- **Rich parameter metadata** - Optional `@Parameter` annotation for titles, descriptions, validation
- **Automatic schema generation** - Dart types mapped to JSON Schema
- **Optional parameter support** - Named and optional positional parameters
- **Doc comment extraction** - Falls back to doc comments when description not provided

## Development

### Prerequisites

- Dart SDK ^3.11.0
- Melos (for workspace management)

### Commands

```bash
# Install dependencies
melos bootstrap

# Run all tests
melos run test

# Analyze code
melos run analyze

# Format code
melos run format

# Rebuild generated code
melos run build
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

If you find this project useful, consider supporting its development:

- [Buy me a coffee](https://buymeacoffee.com/cdavis)
