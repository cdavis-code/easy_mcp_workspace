# MCP Generator dart_mcp Integration Design

**Date:** 2026-04-13
**Status:** Approved

## Overview

Rewrite the MCP generator templates to produce code using the official `dart_mcp` package (v0.5.0) instead of raw JSON-RPC protocol handling.

## Architecture

### Generated Server Structure

Each generated `.mcp.dart` file will:

1. Import `package:dart_mcp/server.dart` and `package:dart_mcp/stdio.dart`
2. Define a `main()` that creates the server with `stdioChannel(input: io.stdin, output: io.stdout)`
3. Extend `MCPServer` with `ToolsSupport` mixin
4. Register tools via `registerTool(Tool(...), handler)` in constructor
5. Use `Schema.*` builders for input schemas
6. Return `CallToolResult(content: [TextContent(text: ...)])` from handlers

### Schema Mapping

| Dart Type | Schema Builder |
|-----------|---------------|
| `String` | `Schema.string()` |
| `int` | `Schema.int()` |
| `double` | `Schema.number()` |
| `bool` | `Schema.bool()` |
| `List<T>` | `Schema.list(items: Schema.<type>())` |
| Optional param | Omitted from `required` list |

### Result Serialization

- Objects with `toJson()` → `jsonEncode(obj.toJson())`
- Lists → `jsonEncode(list.map((e) => e.toJson()).toList())`
- Primitives → `toString()`

### Dependencies

- Add `dart_mcp: ^0.5.0` to example's pubspec.yaml
- Remove `shelf` dependency from HTTP template (dart_mcp handles stdio)

## Files to Modify

1. `packages/mcp_generator/lib/builder/templates.dart` - Rewrite StdioTemplate and HttpTemplate
2. `packages/mcp_generator/test/templates_test.dart` - Update test expectations
3. `example/pubspec.yaml` - Add dart_mcp dependency

## Implementation Notes

- Keep the same builder logic in `mcp_builder.dart` - only templates change
- Tool metadata extraction (name, description, parameters) remains the same
- Generated code follows the pattern from `dart_mcp/example/tools_server.dart`
