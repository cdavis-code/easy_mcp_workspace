# Data Model: MCP Annotations

**Phase**: 1 | **Date**: 2026-04-12 | **Branch**: `001-mcp-annotations`

## Entity Definitions

### mcp Annotation

```dart
/// Transport used by the generated server.
enum McpTransport {
  /// Communicate via standard input/output (JSON-RPC).
  stdio,
  /// Run an HTTP server.
  http,
}

/// Marks a method for MCP exposure.
@immutable
class mcp {
  final McpTransport transport;

  const mcp({this.transport = McpTransport.stdio});
}
```

### tool Annotation

```dart
/// Describes an MCP tool.
@immutable
class tool {
  final String? description;
  final List<String>? icons;
  final Map<String, Object?>? execution;

  const tool({
    this.description,
    this.icons,
    this.execution,
  });
}
```

## Generated Tool Metadata

### ToolDefinition Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Tool identifier (Dart function name)"
    },
    "description": {
      "type": "string",
      "description": "Tool description from doc comments or @tool.description"
    },
    "inputSchema": {
      "type": "object",
      "description": "JSON-Schema for tool parameters"
    },
    "icons": {
      "type": "array",
      "items": { "type": "string", "format": "uri" },
      "description": "Icon URLs"
    }
  },
  "required": ["name", "inputSchema"]
}
```

## JSON-Schema Type Mapping

| Dart Type | JSON-Schema | Notes |
|-----------|------------|-------|
| `int` | `{"type": "integer"}` | |
| `double` | `{"type": "number"}` | |
| `String` | `{"type": "string"}` | |
| `bool` | `{"type": "boolean"}` | |
| `List<T>` | `{"type": "array", "items": ...}` | Recursive |
| `Map<K,V>` | `{"type": "object", "additionalProperties": ...}` | |
| `dynamic` | `{"type": "object"}` | |
| `void` | N/A | No input schema |
| `Future<T>` | `{"type": "..."}` | Unwrap Future |
| `Null` | `{"type": "null"}` | |

## Generated Server Code Structure

### Stdio Server Template

```dart
// Generated stdio server
import 'dart:convert';
import 'dart:async';

final _tools = <String, Tool>{};

void main() async {
  final stdin = stdin.transform(utf8.decoder).transform(const LineSplitter());
  
  await for (final line in stdin) {
    if (line.isEmpty) continue;
    final request = jsonDecode(line) as Map<String, dynamic>;
    final response = await _handleRequest(request);
    if (response != null) {
      print(jsonEncode(response));
    }
  }
}

Future<Map<String, dynamic>> _handleRequest(Map<String, dynamic> request) async {
  final method = request['method'] as String?;
  final id = request['id'];
  
  switch (method) {
    case 'initialize':
      return _initialize(id);
    case 'tools/list':
      return _listTools(id);
    case 'tools/call':
      return _callTool(id, request['params'] as Map<String, dynamic>);
    default:
      return _error(id, -32601, 'Method not found');
  }
}
```

## Contract: Generator Output

### Input

- Dart source files with `@mcp` and/or `@tool` annotations
- Functions must be top-level or belong to annotated class

### Output

1. **`.mcp.dart`** – Generated server code
2. **`.mcp.json`** – Tool metadata (JSON-Schema)

### File Naming

| Source | Generated |
|--------|------------|
| `lib/src/tools.dart` | `lib/src/tools.mcp.dart` |
| `lib/src/tools.dart` | `lib/src/tools.mcp.json` |

## Error Codes (JSON-RPC)

| Code | Meaning |
|------|---------|
| -32700 | Parse error |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |

## Assumptions

1. All annotated functions are `top-level` or `static`
2. User handles their own function implementation
3. Generator only produces boilerplate (dispatch, serialization)
4. User registers their tools in generated `_tools` map