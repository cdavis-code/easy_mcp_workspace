import 'package:mcp_generator/builder/templates.dart';
import 'package:test/test.dart';

void main() {
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
          'sourceImport': 'package:example/user_store.dart',
          'sourceAlias': 'user_store',
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
          'sourceImport': 'package:example/user_store.dart',
          'sourceAlias': 'user_store',
        },
      ];
    });

    test('generates valid Dart code', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains("import 'package:dart_mcp/server.dart';"));
      expect(result, contains("import 'package:dart_mcp/stdio.dart';"));
      expect(
        result,
        contains("import 'package:example/user_store.dart' as user_store;"),
      );
    });

    test('includes MCPServer with ToolsSupport', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('includes all tool names in registerTool', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains("name: 'getUser'"));
      expect(result, contains("name: 'createUser'"));
    });

    test('includes tool descriptions', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('Get user by ID'));
      expect(result, contains('Create a new user'));
    });

    test('uses Schema.* builders', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('Schema.int()'));
      expect(result, contains('Schema.string()'));
      expect(result, contains('Schema.object('));
    });

    test('generates handler methods with CallToolResult', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('CallToolResult'));
      expect(result, contains('TextContent'));
    });

    test('uses await for async tools', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('await user_store.getUser'));
      expect(result, contains('await user_store.createUser'));
    });

    test('does not use await for sync tools', () {
      final syncTools = [
        <String, dynamic>{
          'name': 'searchUsers',
          'description': 'Search users',
          'parameters': <Map<String, dynamic>>[],
          'isAsync': false,
          'sourceImport': 'package:example/user_store.dart',
          'sourceAlias': 'user_store',
        },
      ];
      final result = StdioTemplate.generate(syncTools);
      expect(result, contains('user_store.searchUsers'));
      expect(result, isNot(contains('await user_store.searchUsers')));
    });

    test('handles empty tools list', () {
      final result = StdioTemplate.generate([]);
      expect(result, contains('MCPServerWithTools'));
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('uses stdioChannel', () {
      final result = StdioTemplate.generate(tools);
      expect(result, contains('stdioChannel'));
    });
  });

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
          'sourceImport': 'package:example/user_store.dart',
          'sourceAlias': 'user_store',
        },
      ];
    });

    test('generates valid Dart code', () {
      final result = HttpTemplate.generate(tools, 3000);
      expect(result, contains("import 'package:dart_mcp/server.dart';"));
      expect(result, contains("import 'package:shelf/shelf.dart' as shelf;"));
      expect(
        result,
        contains("import 'package:example/user_store.dart' as user_store;"),
      );
    });

    test('includes correct port in instructions', () {
      final result = HttpTemplate.generate(tools, 8080);
      expect(result, contains('port 8080'));
    });

    test('includes MCPServer with ToolsSupport', () {
      final result = HttpTemplate.generate(tools, 3000);
      expect(result, contains('extends MCPServer with ToolsSupport'));
    });

    test('generates dispatch cases', () {
      final result = HttpTemplate.generate(tools, 3000);
      expect(result, contains('_getUser'));
      expect(result, contains('await user_store.getUser'));
    });

    test('uses Schema.* builders', () {
      final result = HttpTemplate.generate(tools, 3000);
      expect(result, contains('Schema.int()'));
      expect(result, contains('Schema.object('));
    });

    test('generates handler methods with CallToolResult', () {
      final result = HttpTemplate.generate(tools, 3000);
      expect(result, contains('CallToolResult'));
      expect(result, contains('TextContent'));
    });
  });
}
