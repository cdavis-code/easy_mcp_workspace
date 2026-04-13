# Research: MCP Annotations Library

**Phase**: 0 | **Date**: 2026-04-12 | **Branch**: `001-mcp-annotations`

## Research Questions

### RQ1: JSON-RPC Protocol Format

**Question**: What is the exact JSON-RPC message format for MCP stdio transport?

**Answer** (from MCP spec):
- MCP uses JSON-RPC 2.0 as wire format
- Messages are newline-delimited (one JSON object per line)
- Each message MUST be valid JSON on a single line (no embedded newlines)
- stdout for JSON-RPC messages only
- stderr for logging only

**Example Request**:
```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}
```

**Example Response**:
```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-03-26","capabilities":{},"serverInfo":{"name":"mcp-server","version":"1.0.0"}}}
```

**Source**: MCP Specification (modelcontextprotocol.io/specification/latest/basic/transports)

---

### RQ2: MCP HTTP Transport Endpoint Structure

**Question**: How should the Streamable HTTP transport be structured?

**Answer** (from MCP spec):
- Single HTTP endpoint (e.g., `/mcp`)
- Supports POST for sending JSON-RPC requests
- Supports GET for receiving streamed responses (SSE)
- Requires `MCP-Protocol-Version` header
- Uses standard HTTP status codes

**Request Format**:
```
POST /mcp
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25

{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{...}}
```

**Source**: MCP Specification (Streamable HTTP transport section)

---

### RQ3: JSON-Schema Generation via dart:analyzer

**Question**: How to generate JSON-Schema from Dart function signatures using analyzer?

**Answer**:
- Use `analyzer` package to parse function parameter types
- Map Dart types to JSON-Schema types:
  - `int` → `{"type": "integer"}`
  - `double` → `{"type": "number"}`
  - `String` → `{"type": "string"}`
  - `bool` → `{"type": "boolean"}`
  - `List<T>` → `{"type": "array", "items": ...}`
  - `Map<K,V>` / `Object` → `{"type": "object"}`
- Use `FunctionType` to get parameter list
- Use `ParameterMetadata` for optional/required flags

**Implementation Approach**:
- Analyzer provides `FunctionType` via `LibraryElement`
- Use `DartType.getDisplayString()` for type names
- Recursively parse nested types (List, Map, custom classes)

**Source**: `package:analyzer` API documentation

---

### RQ4: Tool Definition Schema

**Question**: What is the MCP tool definition schema?

**Answer** (from MCP spec):
```json
{
  "name": "tool_name",
  "description": "What the tool does",
  "inputSchema": {
    "type": "object",
    "properties": {
      "paramName": {"type": "string"}
    },
    "required": ["paramName"]
  }
}
```

**Tools are exposed via** `tools/list` and `tools/call` methods.

---

### RQ5: Code Generation Approach with source_gen

**Question**: How to use `source_gen` for annotation scanning?

**Answer**:
1. Create a `Generator` subclass that extends `GeneratorForAnnotation`
2. Use `@mcp` and `@tool` as the target annotations
3. Override `generateForLibrary` to scan for annotated elements
4. Use `analyzer` to extract function metadata
5. Emit generated code via `yield` statements

**Key Classes**:
- `GeneratorForAnnotation<T>` - base generator for one annotation type
- `BuildStep.writeAsString()` - emit generated file
- `BuilderOptions` - passed builder configuration

**Source**: `package:source_gen` documentation, existing generators (json_serializable)

---

## Key Findings

1. **MCP Protocol**: JSON-RPC 2.0, newline-delimited, strict stdout/stderr separation
2. **Transports**: stdio (local) and Streamable HTTP (remote)
3. **Tool Schema**: Simple name/description/inputSchema structure
4. **Generator**: Use `source_gen` with `GeneratorForAnnotation`
5. **Type Mapping**: Direct Dart type → JSON-Schema mapping via `analyzer`

## Risks & Mitigations

| Risk | Mitigation |
|------|-------------|
| Complex nested types in Dart | Support common types; warn for unsupported |
| Doc comment extraction edge cases | Use analyzer's built-in doc token handling |
| Version compatibility | Target latest MCP spec (2025-03-26) |

## References

- MCP Spec: https://modelcontextprotocol.io/specification/latest
- JSON-RPC 2.0: https://www.jsonrpc.org/specification
- dart:analyzer: https://pub.dev/packages/analyzer
- source_gen: https://pub.dev/packages/source_gen