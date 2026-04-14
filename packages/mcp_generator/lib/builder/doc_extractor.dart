// DocExtractor - extracts tool info from annotated functions
// This is a placeholder that will be fully implemented with analyzer integration

/// Information about a tool extracted from annotations.
class ToolInfo {
  final String name;
  final String description;
  final List<ParameterInfo> parameters;

  ToolInfo({
    required this.name,
    required this.description,
    required this.parameters,
  });

  /// Generate JSON-Schema for tool parameters.
  Map<String, dynamic> toJsonSchema() {
    final properties = <String, dynamic>{};
    final requiredParams = <String>[];

    for (final param in parameters) {
      properties[param.name] = _dartTypeToJsonSchema(param.type);
      if (!param.isOptional) requiredParams.add(param.name);
    }

    return {
      'type': 'object',
      'properties': properties,
      if (requiredParams.isNotEmpty) 'required': requiredParams,
    };
  }

  Map<String, dynamic> _dartTypeToJsonSchema(String dartType) {
    switch (dartType) {
      case 'int':
      case 'int?':
        return {'type': 'integer'};
      case 'double':
      case 'double?':
        return {'type': 'number'};
      case 'String':
      case 'String?':
        return {'type': 'string'};
      case 'bool':
      case 'bool?':
        return {'type': 'boolean'};
      case 'List':
      case 'List?':
        return {'type': 'array', 'items': {}};
      case 'Map':
      case 'Map?':
        return {'type': 'object'};
      default:
        return {'type': 'object'};
    }
  }
}

/// Information about a parameter.
class ParameterInfo {
  final String name;
  final String type;
  final bool isOptional;

  ParameterInfo({
    required this.name,
    required this.type,
    this.isOptional = false,
  });
}

/// Extracts documentation comments from Dart elements.
/// Currently uses simple regex-based extraction - will integrate with analyzer later.
class DocExtractor {
  /// Extract doc comment from function source, joining multilines with spaces.
  static String? extractDocComment(String source, String functionName) {
    final pattern = RegExp(
      r'///\s*(.*?)\n\s*(?:void|String|int|bool|List|Map|Future)[^]*?\b' +
          RegExp.escape(functionName) +
          r'\s*\(',
      multiLine: true,
    );

    final match = pattern.firstMatch(source);
    if (match == null) return null;

    final docLines = <String>[];
    final lines = source.split('\n');
    final startIndex = match.start;

    for (var i = startIndex - 1; i >= 0 && i >= startIndex - 10; i--) {
      final line = lines[i];
      if (!line.trim().startsWith('///')) break;
      docLines.insert(0, line.replaceFirst('///', '').trim());
    }

    if (docLines.isEmpty) return null;
    return docLines.join(' ').replaceAll(r'\s+', ' ').trim();
  }

  /// Default description when no doc comment available.
  static String defaultDescription(String toolName) {
    return 'Tool $toolName';
  }
}
