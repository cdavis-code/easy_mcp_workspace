# Easy MCP

A Dart code generator that transforms annotated functions into Model Context Protocol (MCP) servers.

## Overview

Easy MCP allows you to expose Dart library functions as MCP tools using simple annotations. The generator produces ready-to-run stdio or HTTP servers that comply with the MCP specification.

## Packages

| Package | Description |
|---------|-------------|
| `mcp_annotations` | Annotation definitions (`@mcp`, `@tool`) |
| `mcp_generator` | Build runner generator that produces MCP server code |

## Quick Start

### 1. Add Dependencies

```yaml
dependencies:
  mcp_annotations:
    path: ../packages/mcp_annotations

dev_dependencies:
  build_runner: any
  mcp_generator:
    path: ../packages/mcp_generator
```

### 2. Annotate Your Functions

```dart
import 'package:mcp_annotations/mcp_annotations.dart';

@mcp(transport: McpTransport.stdio)
@tool(description: 'Get user by ID')
Future<User> getUser(int id) async {
  // ...
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

### `@mcp`

Controls the transport type for the generated server.

```dart
@mcp(transport: McpTransport.stdio)  // Default
@mcp(transport: McpTransport.http)   // HTTP server using shelf
```

### `@tool`

Marks a function as an MCP tool and provides metadata.

```dart
@tool(description: 'Create a new user')
@tool(description: 'Search users', icons: ['https://...'])
```

If `description` is omitted, the function's doc comment is used.

## Features

- **AST-based parsing** - Uses `dart:analyzer` for reliable code extraction
- **Two transport modes** - stdio (JSON-RPC) and HTTP (Shelf-based)
- **Automatic schema generation** - Dart types mapped to JSON Schema
- **Optional parameter support** - Named and optional positional parameters
- **Doc comment extraction** - Falls back to doc comments when description not provided

## Development

### Prerequisites

- Dart SDK ^3.9.0
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
