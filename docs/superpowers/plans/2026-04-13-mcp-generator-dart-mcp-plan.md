# MCP Generator dart_mcp Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite MCP generator templates to produce code using the official `dart_mcp` package instead of raw JSON-RPC.

**Architecture:** Generated servers will extend `MCPServer` with `ToolsSupport` mixin, use `registerTool()` with `Schema.*` builders, and return `CallToolResult`. Stdio transport via `stdioChannel()`.

**Tech Stack:** Dart 3.9+, dart_mcp ^0.5.0, build ^2.4.1, source_gen ^2.0.0

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `packages/mcp_generator/lib/builder/templates.dart` | Modify | Rewrite StdioTemplate and HttpTemplate to generate dart_mcp code |
| `packages/mcp_generator/lib/builder/schema_builder.dart` | Create | Helper to convert parameter metadata to `Schema.*` Dart code |
| `packages/mcp_generator/test/templates_test.dart` | Modify | Update test expectations for dart_mcp patterns |
| `packages/mcp_generator/test/schema_builder_test.dart` | Create | Test schema generation helpers |
| `example/pubspec.yaml` | Modify | Add dart_mcp dependency |
| `example/bin/example.mcp.dart` | Regenerate | Verify build_runner produces valid dart_mcp code |

## Task 1: Add dart_mcp dependency to example

**Files:**
- Modify: `example/pubspec.yaml`

- [ ] **Step 1: Add dart_mcp dependency**

Add to `example/pubspec.yaml` dependencies:
```yaml
dependencies:
  mcp_annotations:
    path: ../packages/mcp_annotations
  dart_mcp: ^0.5.0
```

- [ ] **Step 2: Run pub get and verify**

Run: `dart pub get`
Expected: Success, dart_mcp resolved

- [ ] **Step 3: Commit**

```bash
git add example/pubspec.yaml
git commit -m "feat: add dart_mcp dependency to example"
```

## Task 2: Create schema_builder.dart helper

**Files:**
- Create: `packages/mcp_generator/lib/builder/schema_builder.dart`

- [ ] **Step 1: Write tests for schema generation**

Create `packages/mcp_generator/test/schema_builder_test.dart`:
```dart
import 'package:mcp_generator/builder/schema_builder.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaBuilder', () {
    test('generates Schema.string() for String type', () {
      expect(SchemaBuilder.fromType('String'), equals('Schema.string()'));
    });

    test('generates Schema.int() for int type', () {
      expect(SchemaBuilder.fromType('int'), equals('Schema.int()'));
    });

    test('generates Schema.number() for double type', () {
      expect(SchemaBuilder.fromType('double'), equals('Schema.number()'));
    });

    test('generates Schema.bool() for bool type', () {
      expect(SchemaBuilder.fromType('bool'), equals('Schema.bool()'));
    });

    test('generates Schema.list() for List type', () {
      expect(
        SchemaBuilder.fromType('List<String>'),
        equals('Schema.list(items: Schema.string())'),
      );
    });

    test('generates Schema.string() for unknown types', () {
      expect(SchemaBuilder.fromType('CustomClass'), equals('Schema.string()'));
    });
  });

  group('SchemaBuilder.buildObjectSchema', () {
    test('generates object schema with properties', () {
      final params = [
        {'name': 'id', 'type': 'int', 'isOptional': false},
        {'name': 'name', 'type': 'String', 'isOptional': false},
        {'name': 'email', 'type': 'String', 'isOptional': true},
      ];
      final result = SchemaBuilder.buildObjectSchema(params);
      expect(result, contains('Schema.object('));
      expect(result, contains("'id': Schema.int()"));
      expect(result, contains("'name': Schema.string()"));
      expect(result, contains("'email': Schema.string()"));
      expect(result, contains("required: ['id', 'name']"));
    });

    test('generates empty schema for no params', () {
      final result = SchemaBuilder.buildObjectSchema([]);
      expect(result, equals('Schema.object()'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test packages/mcp_generator/test/schema_builder_test.dart`
Expected: FAIL with "SchemaBuilder not defined"

- [ ] **Step 3: Implement SchemaBuilder**

Create `packages/mcp_generator/lib/builder/schema_builder.dart`:
```dart
/// Generates dart_mcp Schema.* code from parameter metadata.
class SchemaBuilder {
  /// Converts a Dart type string to a Schema.* expression.
  static String fromType(String type) {
    // Handle List<T>
    final listMatch = RegExp(r'^List<(.+)>$').firstMatch(type);
    if (listMatch != null) {
      final itemType = listMatch.group(1)!;
      return 'Schema.list(items: ${fromType(itemType)})';
    }

    switch (type) {
      case 'String':
        return 'Schema.string()';
      case 'int':
        return 'Schema.int()';
      case 'double':
        return 'Schema.number()';
      case 'bool':
        return 'Schema.bool()';
      default:
        return 'Schema.string()';
    }
  }

  /// Builds a Schema.object() expression from a list of parameter maps.
  /// Each param map has: 'name', 'type', 'isOptional'
  static String buildObjectSchema(List<Map<String, dynamic>> params) {
    if (params.isEmpty) {
      return 'Schema.object()';
    }

    final properties = params.map((p) {
      final name = p['name'] as String;
      final type = p['type'] as String;
      return "'$name': ${fromType(type)}";
    }).join(',\n      ');

    final required = params
        .where((p) => p['isOptional'] != true)
        .map((p) => "'${p['name']}'")
        .join(', ');

    if (required.isEmpty) {
      return 'Schema.object(\n    properties: {\n      $properties,\n    },\n  )';
    }

    return 'Schema.object(\n    properties: {\n      $properties,\n    },\n    required: [$required],\n  )';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test packages/mcp_generator/test/schema_builder_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/mcp_generator/lib/builder/schema_builder.dart packages/mcp_generator/test/schema_builder_test.dart
git commit -m "feat: add SchemaBuilder helper for dart_mcp schema generation"
```

## Task 3: Rewrite StdioTemplate for dart_mcp

**Files:**
- Modify: `packages/mcp_generator/lib/builder/templates.dart`
- Test: `packages/mcp_generator/test/templates_test.dart`

- [ ] **Step 1: Update StdioTemplate.generate to produce dart_mcp code**

Replace the entire `StdioTemplate` class in `packages/mcp_generator/lib/builder/templates.dart`:
```dart
import 'package:mcp_generator/builder/schema_builder.dart';

/// Generates stdio server code from tool definitions using dart_mcp.
class StdioTemplate {
  static String generate(
    List<Map<String, dynamic>> tools,
    String libraryName,
    String inputPath,
  ) {
    final importPath =
        'package:mcp_$libraryName${inputPath.replaceAll('lib', '')}';

    final toolRegistrations = tools.map((t) {
      final name = t['name'] as String;
      final schema = SchemaBuilder.buildObjectSchema(
        (t['parameters'] as List<Map<String, dynamic>>? ?? []),
      );
      return '''
    registerTool(
      Tool(
        name: '$name',
        description: '${t['description'] ?? 'Tool $name'}',
        inputSchema: $schema,
      ),
      _$name,
    );''';
    }).join('\n');

    final toolHandlers = tools.map((t) {
      final name = t['name'] as String;
      final params = t['parameters'] as List<Map<String, dynamic>>? ?? [];
      final paramExtractions = params.map((p) {
        final paramName = p['name'] as String;
        final paramType = p['type'] as String;
        final dartMcpType = SchemaBuilder.fromType(paramType);
        return "    final $paramName = request.arguments!['$paramName'] as ${_dartType(paramType)};";
      }).join('\n');

      final isAsync = t['isAsync'] == true;
      final className = t['className'] as String?;
      final isStatic = t['isStatic'] == true;

      String call;
      if (className != null && isStatic) {
        call = isAsync
            ? 'await lib.$className.$name(${_callArgs(params)})'
            : 'lib.$className.$name(${_callArgs(params)})';
      } else if (className != null) {
        call = isAsync
            ? 'await lib.$className().$name(${_callArgs(params)})'
            : 'lib.$className().$name(${_callArgs(params)})';
      } else {
        call = isAsync
            ? 'await lib.$name(${_callArgs(params)})'
            : 'lib.$name(${_callArgs(params)})';
      }

      return '''
  FutureOr<CallToolResult> _$name(CallToolRequest request) async {
$paramExtractions
    final result = $call;
    return CallToolResult(
      content: [TextContent(text: _serializeResult(result))],
    );
  }''';
    }).join('\n');

    return '''
// Generated MCP stdio server
// DO NOT EDIT - automatically generated by mcp_generator

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

import '$importPath' as lib;

void main() {
  MCPServerWithTools(stdioChannel(input: io.stdin, output: io.stdout));
}

base class MCPServerWithTools extends MCPServer with ToolsSupport {
  MCPServerWithTools(super.channel)
    : super.fromStreamChannel(
        implementation: Implementation(
          name: 'mcp-server',
          version: '1.0.0',
        ),
        instructions: 'Auto-generated MCP server',
      ) {
$toolRegistrations
  }

$toolHandlers

  String _serializeResult(dynamic result) {
    if (result == null) return 'null';
    try {
      if (result is List) {
        final items = result.map((e) {
          if (e == null) return null;
          final toJson = e.toJson;
          if (toJson != null && toJson is Function) return toJson();
          return e.toString();
        }).where((e) => e != null).toList();
        return jsonEncode(items);
      }
      final toJson = result.toJson;
      if (toJson != null && toJson is Function) return jsonEncode(toJson());
      return result.toString();
    } catch (_) {
      return result.toString();
    }
  }
}
''';
  }

  static String _callArgs(List<Map<String, dynamic>> params) {
    return params.map((p) {
      final name = p['name'] as String;
      final isNamed = p['isNamed'] == true;
      return isNamed ? '$name: $name' : name;
    }).join(', ');
  }

  static String _dartType(String type) {
    if (type.startsWith('List<')) return type;
    switch (type) {
      case 'String':
      case 'int':
      case 'double':
      case 'bool':
        return type;
      default:
        return 'dynamic';
    }
  }
}
```

- [ ] **Step 2: Update StdioTemplate tests for dart_mcp patterns**

Replace the `StdioTemplate` test group in `packages/mcp_generator/test/templates_test.dart`:
```dart
  group('StdioTemplate', () {
    late List<Map<String, dynamic>> tools;

    setUp(() {
      tools = [
        <String, dynamic>{
          'name': 'getUser',
          'description': 'Get user by ID',
          'parameters': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'id',
              'type': 'int',
              'schema': "{'type': 'integer'}",
              'schemaMap': {'type': 'integer'},
              'isOptional': false,
            },
          ],
          'isAsync': true,
        },
        <String, dynamic>{
          'name': 'createUser',
          'description': 'Create a new user',
          'parameters': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'name',
              'type': 'String',
              'schema': "{'type': 'string'}",
              'schemaMap': {'type': 'string'},
              'isOptional': false,
            },
            <String, dynamic>{
              'name': 'email',
              'type': 'String',
              'schema': "{'type': 'string'}",
              'schemaMap': {'type': 'string'},
              'isOptional': false,
            },
          ],
          'isAsync': true,
        },
      ];
    });

    test('generates valid Dart code', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('import \'package:dart_mcp/server.dart\';'));
      expect(result, contains('import \'package:dart_mcp/stdio.dart\';'));
      expect(
        result,
        contains("import 'package:mcp_example/example.dart' as lib;"),
      );
    });

    test('includes MCPServer with ToolsSupport', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('includes all tool names in registerTool', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains("name: 'getUser'"));
      expect(result, contains("name: 'createUser'"));
    });

    test('includes tool descriptions', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('Get user by ID'));
      expect(result, contains('Create a new user'));
    });

    test('uses Schema.* builders', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('Schema.int()'));
      expect(result, contains('Schema.string()'));
      expect(result, contains('Schema.object('));
    });

    test('generates handler methods with CallToolResult', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('CallToolResult'));
      expect(result, contains('TextContent'));
    });

    test('uses await for async tools', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('await lib.getUser'));
      expect(result, contains('await lib.createUser'));
    });

    test('does not use await for sync tools', () {
      final syncTools = [
        <String, dynamic>{
          'name': 'searchUsers',
          'description': 'Search users',
          'parameters': <Map<String, dynamic>>[],
          'isAsync': false,
        },
      ];
      final result = StdioTemplate.generate(
        syncTools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('lib.searchUsers'));
      expect(result, isNot(contains('await lib.searchUsers')));
    });

    test('handles empty tools list', () {
      final result = StdioTemplate.generate([], 'example', 'lib/example.dart');
      expect(result, contains('MCPServerWithTools'));
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('uses stdioChannel', () {
      final result = StdioTemplate.generate(
        tools,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('stdioChannel'));
    });
  });
```

- [ ] **Step 3: Run tests to verify**

Run: `dart test packages/mcp_generator/test/templates_test.dart -n StdioTemplate`
Expected: PASS (all StdioTemplate tests)

- [ ] **Step 4: Commit**

```bash
git add packages/mcp_generator/lib/builder/templates.dart packages/mcp_generator/test/templates_test.dart
git commit -m "feat: rewrite StdioTemplate to generate dart_mcp code"
```

## Task 4: Rewrite HttpTemplate for dart_mcp

**Files:**
- Modify: `packages/mcp_generator/lib/builder/templates.dart`
- Modify: `packages/mcp_generator/test/templates_test.dart`

- [ ] **Step 1: Update HttpTemplate.generate to produce dart_mcp code**

Replace the entire `HttpTemplate` class in `packages/mcp_generator/lib/builder/templates.dart`:
```dart
/// Generates HTTP server code from tool definitions using dart_mcp.
class HttpTemplate {
  static String generate(
    List<Map<String, dynamic>> tools,
    int port,
    String libraryName,
    String inputPath,
  ) {
    final importPath =
        'package:mcp_$libraryName${inputPath.replaceAll('lib', '')}';

    final toolRegistrations = tools.map((t) {
      final name = t['name'] as String;
      final schema = SchemaBuilder.buildObjectSchema(
        (t['parameters'] as List<Map<String, dynamic>>? ?? []),
      );
      return '''
    registerTool(
      Tool(
        name: '$name',
        description: '${t['description'] ?? 'Tool $name'}',
        inputSchema: $schema,
      ),
      _$name,
    );''';
    }).join('\n');

    final toolHandlers = tools.map((t) {
      final name = t['name'] as String;
      final params = t['parameters'] as List<Map<String, dynamic>>? ?? [];
      final paramExtractions = params.map((p) {
        final paramName = p['name'] as String;
        final paramType = p['type'] as String;
        return "    final $paramName = request.arguments!['$paramName'] as ${_dartType(paramType)};";
      }).join('\n');

      final isAsync = t['isAsync'] == true;
      final className = t['className'] as String?;
      final isStatic = t['isStatic'] == true;

      String call;
      if (className != null && isStatic) {
        call = isAsync
            ? 'await lib.$className.$name(${_callArgs(params)})'
            : 'lib.$className.$name(${_callArgs(params)})';
      } else if (className != null) {
        call = isAsync
            ? 'await lib.$className().$name(${_callArgs(params)})'
            : 'lib.$className().$name(${_callArgs(params)})';
      } else {
        call = isAsync
            ? 'await lib.$name(${_callArgs(params)})'
            : 'lib.$name(${_callArgs(params)})';
      }

      return '''
  FutureOr<CallToolResult> _$name(CallToolRequest request) async {
$paramExtractions
    final result = $call;
    return CallToolResult(
      content: [TextContent(text: _serializeResult(result))],
    );
  }''';
    }).join('\n');

    return '''
// Generated MCP HTTP server
// DO NOT EDIT - automatically generated by mcp_generator

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

import '$importPath' as lib;

void main() {
  MCPServerWithTools(stdioChannel(input: io.stdin, output: io.stdout));
}

base class MCPServerWithTools extends MCPServer with ToolsSupport {
  MCPServerWithTools(super.channel)
    : super.fromStreamChannel(
        implementation: Implementation(
          name: 'mcp-server',
          version: '1.0.0',
        ),
        instructions: 'Auto-generated MCP server on port $port',
      ) {
$toolRegistrations
  }

$toolHandlers

  String _serializeResult(dynamic result) {
    if (result == null) return 'null';
    try {
      if (result is List) {
        final items = result.map((e) {
          if (e == null) return null;
          final toJson = e.toJson;
          if (toJson != null && toJson is Function) return toJson();
          return e.toString();
        }).where((e) => e != null).toList();
        return jsonEncode(items);
      }
      final toJson = result.toJson;
      if (toJson != null && toJson is Function) return jsonEncode(toJson());
      return result.toString();
    } catch (_) {
      return result.toString();
    }
  }
}
''';
  }

  static String _callArgs(List<Map<String, dynamic>> params) {
    return params.map((p) {
      final name = p['name'] as String;
      final isNamed = p['isNamed'] == true;
      return isNamed ? '$name: $name' : name;
    }).join(', ');
  }

  static String _dartType(String type) {
    if (type.startsWith('List<')) return type;
    switch (type) {
      case 'String':
      case 'int':
      case 'double':
      case 'bool':
        return type;
      default:
        return 'dynamic';
    }
  }
}
```

- [ ] **Step 2: Update HttpTemplate tests for dart_mcp patterns**

Replace the `HttpTemplate` test group in `packages/mcp_generator/test/templates_test.dart`:
```dart
  group('HttpTemplate', () {
    late List<Map<String, dynamic>> tools;

    setUp(() {
      tools = [
        <String, dynamic>{
          'name': 'getUser',
          'description': 'Get user by ID',
          'parameters': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'id',
              'type': 'int',
              'schema': "{'type': 'integer'}",
              'schemaMap': {'type': 'integer'},
              'isOptional': false,
            },
          ],
          'isAsync': true,
        },
      ];
    });

    test('generates valid Dart code', () {
      final result = HttpTemplate.generate(
        tools,
        3000,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('import \'package:dart_mcp/server.dart\';'));
      expect(result, contains('import \'package:dart_mcp/stdio.dart\';'));
      expect(
        result,
        contains("import 'package:mcp_example/example.dart' as lib;"),
      );
    });

    test('includes correct port in instructions', () {
      final result = HttpTemplate.generate(
        tools,
        8080,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('port 8080'));
    });

    test('includes MCPServer with ToolsSupport', () {
      final result = HttpTemplate.generate(
        tools,
        3000,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('generates dispatch cases', () {
      final result = HttpTemplate.generate(
        tools,
        3000,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('_getUser'));
      expect(result, contains('await lib.getUser'));
    });

    test('uses Schema.* builders', () {
      final result = HttpTemplate.generate(
        tools,
        3000,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('Schema.int()'));
      expect(result, contains('Schema.object('));
    });

    test('generates handler methods with CallToolResult', () {
      final result = HttpTemplate.generate(
        tools,
        3000,
        'example',
        'lib/example.dart',
      );
      expect(result, contains('CallToolResult'));
      expect(result, contains('TextContent'));
    });
  });
```

- [ ] **Step 3: Run tests to verify**

Run: `dart test packages/mcp_generator/test/templates_test.dart`
Expected: PASS (all tests)

- [ ] **Step 4: Commit**

```bash
git add packages/mcp_generator/lib/builder/templates.dart packages/mcp_generator/test/templates_test.dart
git commit -m "feat: rewrite HttpTemplate to generate dart_mcp code"
```

## Task 5: Rebuild example and verify

**Files:**
- Modify: `example/bin/example.mcp.dart` (regenerated)
- Test: Run example server

- [ ] **Step 1: Clean and rebuild**

```bash
cd example && rm -rf .dart_tool/build && dart run build_runner build --delete-conflicting-outputs
```
Expected: Build succeeds, generates .mcp.dart files

- [ ] **Step 2: Verify generated code uses dart_mcp**

```bash
grep -q "dart_mcp" example/lib/src/user.mcp.dart && echo "PASS" || echo "FAIL"
```
Expected: PASS

- [ ] **Step 3: Run dart analyze**

```bash
dart analyze . --fatal-infos
```
Expected: 0 errors

- [ ] **Step 4: Run all tests**

```bash
dart test packages/mcp_generator/test
```
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add example/
git commit -m "feat: rebuild example with dart_mcp generated code"
```

## Task 6: Self-Review

- [ ] Verify all spec requirements are covered
- [ ] Check for placeholder patterns in plan
- [ ] Verify type consistency across tasks
- [ ] Confirm each task produces working, testable code
