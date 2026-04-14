/// Generates dart_mcp Schema.* code from parameter metadata.
class SchemaBuilder {
  /// Converts a Dart type string to a Schema.* expression.
  static String fromType(String rawType) {
    final type = rawType.endsWith('?')
        ? rawType.substring(0, rawType.length - 1)
        : rawType;
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

  /// Converts a schema map (from _introspectType) to a Schema.* expression.
  static String fromSchemaMap(Map<String, dynamic> schema) {
    final type = schema['type'] as String?;
    switch (type) {
      case 'string':
        return 'Schema.string()';
      case 'integer':
        return 'Schema.int()';
      case 'number':
        return 'Schema.number()';
      case 'boolean':
        return 'Schema.bool()';
      case 'array':
        final items = schema['items'] as Map<String, dynamic>?;
        if (items != null) {
          return 'Schema.list(items: ${fromSchemaMap(items)})';
        }
        return 'Schema.list()';
      case 'object':
        final props = schema['properties'] as Map<String, dynamic>?;
        if (props == null || props.isEmpty) {
          return 'Schema.object()';
        }
        final propEntries = props.entries
            .map((e) {
              return "'${e.key}': ${fromSchemaMap(e.value as Map<String, dynamic>)}";
            })
            .join(',\n      ');
        final required = schema['required'] as List?;
        if (required != null && required.isNotEmpty) {
          final reqStr = required.map((r) => "'$r'").join(', ');
          return 'Schema.object(\n    properties: {\n      $propEntries,\n    },\n    required: [$reqStr],\n  )';
        }
        return 'Schema.object(\n    properties: {\n      $propEntries,\n    },\n  )';
      default:
        return 'Schema.string()';
    }
  }

  /// Builds a Schema.object() expression from a list of parameter maps.
  /// Each param map has: 'name', 'type', 'schemaMap', 'isOptional'
  static String buildObjectSchema(List<Map<String, dynamic>> params) {
    if (params.isEmpty) {
      return 'Schema.object()';
    }

    final properties = params
        .map((p) {
          final name = p['name'] as String;
          final schemaMap = p['schemaMap'] as Map<String, dynamic>?;
          if (schemaMap != null) {
            return "'$name': ${fromSchemaMap(schemaMap)}";
          }
          final type = p['type'] as String;
          return "'$name': ${fromType(type)}";
        })
        .join(',\n      ');

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
