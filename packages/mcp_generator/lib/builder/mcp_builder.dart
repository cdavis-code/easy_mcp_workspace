import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
// ignore: deprecated_member_use
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';
import '../stubs.dart';
import 'templates.dart';

class McpBuilder extends Builder {
  @override
  final buildExtensions = const {
    '.dart': ['.mcp.dart', '.mcp.json'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final resolver = buildStep.resolver;

    if (!await resolver.isLibrary(inputId)) return;

    final library = await buildStep.resolver.libraryFor(inputId);

    // Only process files with @Mcp annotation
    if (!_hasMcpAnnotation(library)) return;

    // Aggregate tools from this library AND all its imports
    final tools = await _extractAllTools(library);

    if (tools.isEmpty) return; // No tools found anywhere

    final transport = _findTransport(library);
    final generated = transport == 'http'
        ? HttpTemplate.generate(tools, 3000)
        : StdioTemplate.generate(tools);

    await buildStep.writeAsString(
      inputId.changeExtension('.mcp.dart'),
      generated,
    );

    if (_shouldGenerateJson(library)) {
      final jsonMetadata = _generateJsonMetadata(tools);
      await buildStep.writeAsString(
        inputId.changeExtension('.mcp.json'),
        jsonEncode(jsonMetadata),
      );
    }
  }

  // ignore: deprecated_member_use
  Future<List<Map<String, dynamic>>> _extractToolsFromLibrary(
    LibraryElement library,
  ) async {
    final tools = <Map<String, dynamic>>[];
    const toolChecker = TypeChecker.fromUrl(
      'package:mcp_annotations/mcp_annotations.dart#Tool',
    );

    // ignore: deprecated_member_use
    for (final unit in library.units) {
      // Top-level functions
      // ignore: deprecated_member_use
      for (final element in unit.children.whereType<FunctionElement>()) {
        final toolAnnotation = toolChecker.firstAnnotationOf(element);
        if (toolAnnotation == null) continue;

        final description = _extractDescription(toolAnnotation, element);
        final parameters = _extractParametersFromElement(element);
        // ignore: deprecated_member_use
        final isAsync = element.returnType.isDartAsyncFuture;

        tools.add(<String, dynamic>{
          'name': element.name,
          'description': description,
          'parameters': parameters,
          'isAsync': isAsync,
        });
      }

      // Class methods
      // ignore: deprecated_member_use
      for (final element in unit.children.whereType<ClassElement>()) {
        // ignore: deprecated_member_use
        for (final method in element.methods) {
          final toolAnnotation = toolChecker.firstAnnotationOf(method);
          if (toolAnnotation == null) continue;

          final description = _extractDescription(toolAnnotation, method);
          final parameters = _extractParametersFromElement(method);
          // ignore: deprecated_member_use
          final isAsync = method.returnType.isDartAsyncFuture;

          tools.add(<String, dynamic>{
            'name': method.name,
            'description': description,
            'parameters': parameters,
            'isAsync': isAsync,
            'className': element.name,
            'isStatic': method.isStatic,
          });
        }
      }
    }

    return tools;
  }

  /// Extracts tools from the current library and all package-local imports.
  /// Each tool is annotated with sourceImport and sourceAlias.
  // ignore: deprecated_member_use
  Future<List<Map<String, dynamic>>> _extractAllTools(
    LibraryElement library,
  ) async {
    final allTools = <Map<String, dynamic>>[];
    final aliasCounts = <String, int>{};

    // Get the current library's package name
    final currentPackageUri = library.source.uri.toString();
    final packageName = _extractPackageName(currentPackageUri);

    // Extract tools from the current library (@Mcp file itself)
    final currentLibTools = await _extractToolsFromLibrary(library);
    final currentAlias = _deriveAlias(currentPackageUri);
    for (final tool in currentLibTools) {
      tool['sourceImport'] = currentPackageUri;
      tool['sourceAlias'] = currentAlias;
      allTools.add(tool);
    }

    // Scan imported libraries for tools
    // ignore: deprecated_member_use
    for (final importedLib in library.importedLibraries) {
      final importedUri = importedLib.source.uri.toString();

      // Skip non-package URIs (dart: core libraries)
      if (!importedUri.startsWith('package:')) continue;

      // Skip libraries from other packages
      final importedPackageName = _extractPackageName(importedUri);
      if (importedPackageName != packageName) continue;

      // Extract tools from this imported library
      final importedTools = await _extractToolsFromLibrary(importedLib);
      if (importedTools.isEmpty) continue;

      // Derive alias and ensure uniqueness
      var alias = _deriveAlias(importedUri);
      final count = aliasCounts[alias] ?? 0;
      if (count > 0) {
        alias = '${alias}_$count';
      }
      aliasCounts[alias] = count + 1;

      for (final tool in importedTools) {
        tool['sourceImport'] = importedUri;
        tool['sourceAlias'] = alias;
        allTools.add(tool);
      }
    }

    return allTools;
  }

  /// Extracts the package name from a package URI.
  /// E.g., 'package:mcp_example/src/user.dart' -> 'mcp_example'
  /// Also handles asset URIs: 'asset:mcp_example/bin/example.dart' -> 'mcp_example'
  String _extractPackageName(String uri) {
    // Handle asset: URIs (e.g., for bin/ files)
    if (uri.startsWith('asset:')) {
      final withoutAsset = uri.substring('asset:'.length);
      final slashIndex = withoutAsset.indexOf('/');
      if (slashIndex == -1) return withoutAsset;
      return withoutAsset.substring(0, slashIndex);
    }
    // Handle package: URIs
    if (!uri.startsWith('package:')) return '';
    final withoutPackage = uri.substring('package:'.length);
    final slashIndex = withoutPackage.indexOf('/');
    if (slashIndex == -1) return withoutPackage;
    return withoutPackage.substring(0, slashIndex);
  }

  /// Derives an import alias from a package URI.
  /// E.g., 'package:mcp_example/src/user_store.dart' -> 'user_store'
  /// Also handles asset URIs: 'asset:mcp_example/bin/example.dart' -> 'example'
  String _deriveAlias(String uri) {
    final lastSlash = uri.lastIndexOf('/');
    if (lastSlash == -1) return uri;
    final fileName = uri.substring(lastSlash + 1);
    // Remove .dart extension
    if (fileName.endsWith('.dart')) {
      return fileName.substring(0, fileName.length - '.dart'.length);
    }
    return fileName;
  }

  // ignore: deprecated_member_use
  String _extractDescription(
    DartObject? toolAnnotation,
    ExecutableElement element,
  ) {
    final reader = ConstantReader(toolAnnotation);
    final desc = reader.peek('description');
    if (desc != null) {
      return desc.stringValue;
    }

    // Fall back to doc comment
    if (element.documentationComment != null &&
        element.documentationComment!.isNotEmpty) {
      return _stripDocComment(element.documentationComment!);
    }

    return 'Tool ${element.name}';
  }

  String _stripDocComment(String docComment) {
    return docComment
        .replaceAll(RegExp(r'^///\s?', multiLine: true), '')
        .replaceAll(RegExp(r'^//\s?', multiLine: true), '')
        .trim();
  }

  // ignore: deprecated_member_use
  List<Map<String, dynamic>> _extractParametersFromElement(
    ExecutableElement element,
  ) {
    final params = <Map<String, dynamic>>[];

    for (final param in element.parameters) {
      final typeString = _getTypeString(param.type);
      final isOptional = !param.isRequired;
      final isNamedParam = param.isNamed;

      // Use full introspection for the schema map
      final schemaMap = _introspectType(param.type);

      // Extract import URI for custom List inner types
      final String? listInnerTypeImport = _extractListInnerTypeImport(
        param.type,
      );

      params.add(<String, dynamic>{
        'name': param.name,
        'type': typeString,
        'schema': _dartTypeToJsonSchema(typeString),
        'schemaMap': schemaMap,
        'isOptional': isOptional,
        'isNamed': isNamedParam,
        'listInnerTypeImport': listInnerTypeImport,
      });
    }

    return params;
  }

  /// Extracts the import URI for the inner type of a List<T> if T is a custom type.
  /// Returns null if the type is not a List or if the inner type is a primitive.
  String? _extractListInnerTypeImport(DartType type) {
    // Handle List<T>
    if (type.isDartCoreList) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final itemType = type.typeArguments.first;
        // Check if it's a custom class (not dart:core or dart:async)
        if (_isCustomClass(itemType)) {
          // ignore: deprecated_member_use
          final element = itemType.element;
          if (element != null) {
            // ignore: deprecated_member_use
            final library = element.library;
            if (library != null) {
              return library.source.uri.toString();
            }
          }
        }
      }
    }
    return null;
  }

  String _getTypeString(DartType type) {
    if (type.isDartAsyncFuture) {
      if (type is ParameterizedType) {
        final typeArg = type.typeArguments.first;
        return _getTypeString(typeArg);
      }
      return 'dynamic';
    }
    return type.getDisplayString();
  }

  /// Checks if a type is a custom class (not a dart:core or dart:async type).
  bool _isCustomClass(DartType type) {
    if (type is! InterfaceType) return false;
    final element = type.element;
    // Skip dart:core types (String, int, List, Map, etc.)
    if (element.library.isDartCore) return false;
    // Skip dart:async types (Future, Stream, etc.)
    if (element.library.isDartAsync) return false;
    return true;
  }

  /// Introspects a DartType to generate a full JSON Schema map.
  /// Handles primitives, lists, maps, and custom classes with cycle detection.
  Map<String, dynamic> _introspectType(DartType type, {Set<String>? visited}) {
    visited ??= <String>{};

    // Handle nullable types by unwrapping
    if (type.isDartCoreNull) {
      return <String, dynamic>{'type': 'object'};
    }

    // Handle primitives
    if (type.isDartCoreInt) {
      return <String, dynamic>{'type': 'integer'};
    }
    if (type.isDartCoreDouble || type.isDartCoreNum) {
      return <String, dynamic>{'type': 'number'};
    }
    if (type.isDartCoreString) {
      return <String, dynamic>{'type': 'string'};
    }
    if (type.isDartCoreBool) {
      return <String, dynamic>{'type': 'boolean'};
    }

    // Handle DateTime (commonly used, treated as string with format)
    final typeString = type.getDisplayString();
    if (typeString == 'DateTime') {
      return <String, dynamic>{'type': 'string', 'format': 'date-time'};
    }

    // Handle dynamic
    if (type.getDisplayString() == 'dynamic') {
      return <String, dynamic>{'type': 'object'};
    }

    // Handle List<T>
    if (type.isDartCoreList) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final itemType = type.typeArguments.first;
        return <String, dynamic>{
          'type': 'array',
          'items': _introspectType(itemType, visited: visited),
        };
      }
      return <String, dynamic>{'type': 'array'};
    }

    // Handle Map<K, V>
    if (type.isDartCoreMap) {
      return <String, dynamic>{'type': 'object'};
    }

    // Handle custom classes
    if (_isCustomClass(type)) {
      final typeName = type.getDisplayString();

      // Cycle detection - if we've seen this type, return generic object
      if (visited.contains(typeName)) {
        return <String, dynamic>{'type': 'object'};
      }

      // Add to visited set
      final newVisited = {...visited, typeName};

      if (type is InterfaceType) {
        final classElement = type.element;
        final properties = <String, dynamic>{};
        final requiredFields = <String>[];

        for (final field in classElement.fields) {
          // Skip static fields
          if (field.isStatic) continue;
          // Skip private fields
          if (field.name.startsWith('_')) continue;

          final fieldType = field.type;
          properties[field.name] = _introspectType(
            fieldType,
            visited: newVisited,
          );

          // Add to required if non-nullable (doesn't end with ?) and no default value
          final fieldTypeName = fieldType.getDisplayString();
          final isNullable = fieldTypeName.endsWith('?');
          if (!isNullable) {
            requiredFields.add(field.name);
          }
        }

        final result = <String, dynamic>{
          'type': 'object',
          'properties': properties,
        };

        if (requiredFields.isNotEmpty) {
          result['required'] = requiredFields;
        }

        return result;
      }
    }

    // Default fallback
    return <String, dynamic>{'type': 'object'};
  }

  String _dartTypeToJsonSchema(String rawType) {
    final dartType = rawType.endsWith('?')
        ? rawType.substring(0, rawType.length - 1)
        : rawType;
    switch (dartType) {
      case 'int':
        return "{'type': 'integer'}";
      case 'double':
      case 'num':
        return "{'type': 'number'}";
      case 'String':
        return "{'type': 'string'}";
      case 'bool':
        return "{'type': 'boolean'}";
      case 'List':
        return "{'type': 'array', 'items': <String, dynamic>{}}";
      case 'Map':
      case 'dynamic':
        return "{'type': 'object'}";
      case 'DateTime':
        return "{'type': 'string', 'format': 'date-time'}";
      default:
        if (dartType.startsWith('List<') || dartType.startsWith('Map<')) {
          return "{'type': 'array'}";
        }
        return "{'type': 'object'}";
    }
  }

  Map<String, dynamic> _generateJsonMetadata(List<Map<String, dynamic>> tools) {
    final toolList = <Map<String, dynamic>>[];

    for (final t in tools) {
      final name = t['name'] as String;
      final params = t['parameters'] as List<Map<String, dynamic>>? ?? [];
      final properties = <String, dynamic>{};
      final required = <String>[];

      for (final p in params) {
        properties[p['name']] = p['schemaMap'] ?? {'type': 'object'};
        if (p['isOptional'] != true) required.add(p['name']);
      }

      toolList.add(<String, dynamic>{
        'name': name,
        'description': t['description'],
        'inputSchema': <String, dynamic>{
          'type': 'object',
          'properties': properties,
          if (required.isNotEmpty) 'required': required,
        },
      });
    }

    return <String, dynamic>{'schemaVersion': '1.0', 'tools': toolList};
  }

  /// Checks if the library has an @Mcp annotation.
  // ignore: deprecated_member_use
  bool _hasMcpAnnotation(LibraryElement library) {
    const mcpChecker = TypeChecker.fromUrl(
      'package:mcp_annotations/mcp_annotations.dart#Mcp',
    );

    // ignore: deprecated_member_use
    for (final unit in library.units) {
      // ignore: deprecated_member_use
      for (final element in unit.children) {
        final annotation = mcpChecker.firstAnnotationOf(element);
        if (annotation != null) {
          return true;
        }
      }
    }

    return false;
  }

  // ignore: deprecated_member_use
  bool _shouldGenerateJson(LibraryElement library) {
    const mcpChecker = TypeChecker.fromUrl(
      'package:mcp_annotations/mcp_annotations.dart#Mcp',
    );

    // ignore: deprecated_member_use
    for (final unit in library.units) {
      // ignore: deprecated_member_use
      for (final element in unit.children) {
        final annotation = mcpChecker.firstAnnotationOf(element);
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          final generateJson = reader.peek('generateJson');
          if (generateJson != null) {
            return generateJson.boolValue;
          }
        }
      }
    }

    return false;
  }

  // ignore: deprecated_member_use
  String _findTransport(LibraryElement library) {
    const mcpChecker = TypeChecker.fromUrl(
      'package:mcp_annotations/mcp_annotations.dart#Mcp',
    );

    // ignore: deprecated_member_use
    for (final unit in library.units) {
      // ignore: deprecated_member_use
      for (final element in unit.children) {
        final annotation = mcpChecker.firstAnnotationOf(element);
        if (annotation != null) {
          final reader = ConstantReader(annotation);
          final transport = reader.peek('transport');
          if (transport != null) {
            final transportField = transport.objectValue.getField('index');
            if (transportField != null) {
              final transportValue = transportField.toIntValue();
              if (transportValue == 1) return 'http';
            }
          }
        }
      }
    }

    return 'stdio';
  }
}

Builder mcpBuilder(BuilderOptions options) => McpBuilder();
