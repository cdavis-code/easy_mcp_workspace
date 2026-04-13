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

    final properties = params
        .map((p) {
          final name = p['name'] as String;
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
