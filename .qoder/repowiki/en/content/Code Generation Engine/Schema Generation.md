# Schema Generation

<cite>
**Referenced Files in This Document**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_generator.dart](file://packages/easy_mcp_generator/lib/mcp_generator.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)
- [templates.dart](file://packages/easy_mcp_generator/lib/builder/templates.dart)
- [user_store.dart](file://example/lib/src/user_store.dart)
- [todo.dart](file://example/lib/src/todo.dart)
- [user.dart](file://example/lib/src/user.dart)
- [pubspec.yaml](file://packages/easy_mcp_generator/pubspec.yaml)
- [pubspec.yaml](file://packages/easy_mcp_annotations/pubspec.yaml)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)
10. [Appendices](#appendices)

## Introduction
This document explains the JSON Schema generation subsystem responsible for automatically constructing JSON Schemas from Dart types. It covers how the generator performs type introspection, maps Dart primitives and generics to JSON Schema equivalents, detects cycles in object graphs, and produces both a Dart-side schema representation and a JSON metadata file consumed by MCP clients. It also documents required field detection, optional parameter handling, collection and nullable type support, and practical guidance for customization, versioning, backward compatibility, and performance.

## Project Structure
The schema generation capability spans two packages:
- easy_mcp_annotations: Defines annotations that drive code generation and optional JSON metadata emission.
- easy_mcp_generator: Implements the build-time generator that extracts tool metadata, introspects Dart types, builds JSON Schemas, and writes both Dart and JSON artifacts.

Key files:
- Annotations: packages/easy_mcp_annotations/lib/mcp_annotations.dart
- Generator entrypoint: packages/easy_mcp_generator/lib/mcp_generator.dart
- Core builder: packages/easy_mcp_generator/lib/builder/mcp_builder.dart
- Schema builder: packages/easy_mcp_generator/lib/builder/schema_builder.dart
- Templates: packages/easy_mcp_generator/lib/builder/templates.dart
- Examples: example/lib/src/user_store.dart, example/lib/src/todo.dart, example/lib/src/user.dart

```mermaid
graph TB
subgraph "Annotations"
A["mcp_annotations.dart"]
end
subgraph "Generator"
G["mcp_generator.dart"]
B["mcp_builder.dart"]
S["schema_builder.dart"]
T["templates.dart"]
end
subgraph "Examples"
U["user_store.dart"]
D["todo.dart"]
R["user.dart"]
end
A --> G
G --> B
B --> S
B --> T
U --> B
D --> B
R --> B
```

**Diagram sources**
- [mcp_annotations.dart:1-107](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart#L1-L107)
- [mcp_generator.dart:1-14](file://packages/easy_mcp_generator/lib/mcp_generator.dart#L1-L14)
- [mcp_builder.dart:1-567](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L1-L567)
- [schema_builder.dart:1-99](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L1-L99)
- [templates.dart:1-578](file://packages/easy_mcp_generator/lib/builder/templates.dart#L1-L578)
- [user_store.dart:1-144](file://example/lib/src/user_store.dart#L1-L144)
- [todo.dart:1-46](file://example/lib/src/todo.dart#L1-L46)
- [user.dart:1-42](file://example/lib/src/user.dart#L1-L42)

**Section sources**
- [mcp_generator.dart:1-14](file://packages/easy_mcp_generator/lib/mcp_generator.dart#L1-L14)
- [mcp_builder.dart:1-567](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L1-L567)
- [schema_builder.dart:1-99](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L1-L99)
- [templates.dart:1-578](file://packages/easy_mcp_generator/lib/builder/templates.dart#L1-L578)
- [mcp_annotations.dart:1-107](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart#L1-L107)

## Core Components
- Annotations: Provide configuration for transport and JSON metadata generation.
- McpBuilder: Extracts tools, introspects parameter types, builds schema maps, and emits .mcp.dart and .mcp.json outputs.
- SchemaBuilder: Translates schema maps into dart_mcp Schema.* expressions for code generation.
- Templates: Generate server code and embed the built schemas; also handle list conversion for custom inner types.

Key responsibilities:
- Type introspection and schema map construction
- Required vs optional field detection
- Nullable and collection handling
- Cycle detection for complex object graphs
- JSON metadata emission and versioning

**Section sources**
- [mcp_annotations.dart:39-56](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart#L39-L56)
- [mcp_builder.dart:18-52](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L18-L52)
- [schema_builder.dart:29-66](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L29-L66)
- [templates.dart:29-42](file://packages/easy_mcp_generator/lib/builder/templates.dart#L29-L42)

## Architecture Overview
The generator runs during build time and targets libraries annotated with @Mcp. It scans for @Tool-annotated methods, extracts parameter metadata, performs deep type introspection, and produces:
- A Dart file (.mcp.dart) registering tools with their input schemas
- A JSON metadata file (.mcp.json) with schemaVersion and tool definitions

```mermaid
sequenceDiagram
participant BR as "BuildRunner"
participant MB as "McpBuilder"
participant AN as "@Tool/@Mcp annotations"
participant INT as "Type Introspection"
participant SB as "SchemaBuilder"
participant TM as "Templates"
participant OUT as "Outputs"
BR->>MB : "Resolve library and extensions"
MB->>AN : "Find @Mcp and @Tool"
MB->>MB : "_extractAllTools()"
MB->>INT : "_introspectType(DartType)"
INT-->>MB : "Schema map (object/array/primitive)"
MB->>SB : "fromSchemaMap()/buildObjectSchema()"
SB-->>TM : "Schema.* expressions"
TM-->>OUT : ".mcp.dart"
MB->>MB : "_generateJsonMetadata()"
MB-->>OUT : ".mcp.json"
```

**Diagram sources**
- [mcp_builder.dart:18-52](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L18-L52)
- [mcp_builder.dart:55-166](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L55-L166)
- [mcp_builder.dart:309-411](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L309-L411)
- [schema_builder.dart:29-97](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L29-L97)
- [templates.dart:29-42](file://packages/easy_mcp_generator/lib/builder/templates.dart#L29-L42)

## Detailed Component Analysis

### Type Introspection and Schema Construction
The introspection engine converts Dart types into JSON Schema-like maps with cycle detection and required field inference.

Highlights:
- Primitive mapping: int → integer, double/num → number, String → string, bool → boolean, DateTime → string with date-time format.
- Collections: List<T> → array with items schema derived from T; Map<K,V> → object.
- Custom classes: Recursively build properties map; skip static/private fields; infer required fields from non-nullable types without defaults.
- Nullability: Nullable types are unwrapped for introspection; the final schema marks fields as required based on non-nullability.
- Cycles: Track visited type names; if revisited, emit a generic object to prevent infinite recursion.

```mermaid
flowchart TD
Start(["Introspect DartType"]) --> IsNullable{"Is Null?"}
IsNullable --> |Yes| ReturnObj["Return {type: 'object'}"]
IsNullable --> |No| IsPrimitive{"Is Primitive?"}
IsPrimitive --> |Yes| ReturnPrim["Return {type: '...'}"]
IsPrimitive --> |No| IsDateTime{"Is DateTime?"}
IsDateTime --> |Yes| ReturnDT["Return {type: 'string', format: 'date-time'}"]
IsDateTime --> |No| IsDynamic{"Is dynamic?"}
IsDynamic --> |Yes| ReturnDyn["Return {type: 'object'}"]
IsDynamic --> |No| IsList{"Is List<T>?"}
IsList --> |Yes| Items["items = introspect(T)"]
IsList --> |No| IsMap{"Is Map<K,V>?"}
IsMap --> |Yes| ReturnMap["Return {type: 'object'}"]
IsMap --> |No| IsCustom{"Is Custom Class?"}
IsCustom --> |Yes| Cycle{"Visited?"}
Cycle --> |Yes| ReturnObj
Cycle --> |No| Props["Collect fields<br/>skip static/private<br/>required = !nullable"]
Props --> ReturnObjMap["Return {type:'object', properties, required}"]
Items --> ReturnArr["Return {type:'array', items}"]
ReturnPrim --> End(["Done"])
ReturnDT --> End
ReturnDyn --> End
ReturnMap --> End
ReturnObj --> End
ReturnObjMap --> End
ReturnArr --> End
```

**Diagram sources**
- [mcp_builder.dart:309-411](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L309-L411)

**Section sources**
- [mcp_builder.dart:309-411](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L309-L411)

### Required Field Detection and Optional Parameter Handling
- Required fields: Derived from non-nullable Dart fields (no trailing ?) and absence of default values.
- Optional parameters: Determined by the parameter’s isOptional flag; in the final schema, optional parameters are not included in the required list.
- Named vs positional: Named parameters are supported; the template code extracts arguments accordingly.

Practical implications:
- Fields typed as T? are treated as optional in the schema.
- Parameters without defaults are required; named parameters are supported.

**Section sources**
- [mcp_builder.dart:376-403](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L376-L403)
- [mcp_builder.dart:234-256](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L234-L256)
- [templates.dart:50-62](file://packages/easy_mcp_generator/lib/builder/templates.dart#L50-L62)

### Collections, Nested Objects, and Nullable Types
- Arrays: List<T> mapped to JSON Schema arrays; items schema derived recursively.
- Objects: Custom classes mapped to objects with properties and required arrays.
- Maps: Mapped to generic objects.
- Nullables: Handled by unwrapping for introspection; final schema reflects required/optional based on nullability.
- DateTime: Special-cased to string with date-time format.

**Section sources**
- [mcp_builder.dart:342-357](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L342-L357)
- [mcp_builder.dart:331-335](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L331-L335)
- [mcp_builder.dart:312-315](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L312-L315)

### Cycle Detection Mechanism
To avoid infinite recursion in self-referential or mutually referencing types:
- Maintain a visited set of type names during introspection.
- If a type is encountered again, return a generic object schema instead of recursing further.

This ensures termination and produces a safe, valid schema even for complex graphs.

**Section sources**
- [mcp_builder.dart:363-366](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L363-L366)
- [mcp_builder.dart:309-369](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L309-L369)

### Schema Validation Rules and JSON Metadata
- JSON metadata includes a schemaVersion and a tools array.
- Each tool defines an inputSchema with properties and required arrays.
- The generator derives required fields from parameter and field nullability.

```mermaid
erDiagram
METADATA {
string schemaVersion
}
TOOL {
string name
string description
}
INPUT_SCHEMA {
string type
}
PROPERTY {
string name
string type
}
METADATA ||--o{ TOOL : "contains"
TOOL ||--o{ INPUT_SCHEMA : "has"
INPUT_SCHEMA ||--o{ PROPERTY : "properties"
```

**Diagram sources**
- [mcp_builder.dart:442-468](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L442-L468)

**Section sources**
- [mcp_builder.dart:442-468](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L442-L468)

### Dart-to-Schema Mapping and Template Integration
- SchemaBuilder translates schema maps into dart_mcp Schema.* expressions.
- Templates embed these expressions into generated server code and handle list conversions for custom inner types.

```mermaid
classDiagram
class SchemaBuilder {
+fromType(rawType) String
+fromSchemaMap(schema) String
+buildObjectSchema(params) String
}
class StdioTemplate {
+generate(tools) String
-_needsListConversion(type) bool
-_extractListInnerType(type) String
}
class HttpTemplate {
+generate(tools, port) String
}
SchemaBuilder <.. StdioTemplate : "used by"
SchemaBuilder <.. HttpTemplate : "used by"
```

**Diagram sources**
- [schema_builder.dart:1-99](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L1-L99)
- [templates.dart:29-42](file://packages/easy_mcp_generator/lib/builder/templates.dart#L29-L42)
- [templates.dart:269-296](file://packages/easy_mcp_generator/lib/builder/templates.dart#L269-L296)

**Section sources**
- [schema_builder.dart:29-97](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L29-L97)
- [templates.dart:29-42](file://packages/easy_mcp_generator/lib/builder/templates.dart#L29-L42)
- [templates.dart:269-296](file://packages/easy_mcp_generator/lib/builder/templates.dart#L269-L296)

### Example: Tool Parameter Introspection and Schema Emission
The example demonstrates how a tool with typed parameters is processed:
- A tool method is annotated with @Tool.
- The builder extracts parameters, computes schema maps, and emits both Dart registration and JSON metadata.

```mermaid
sequenceDiagram
participant US as "UserStore"
participant MB as "McpBuilder"
participant INT as "Introspection"
participant SB as "SchemaBuilder"
participant OUT as ".mcp.json"
US->>MB : "@Tool createUser(name : String, email : String)"
MB->>INT : "_introspectType(String)" and "_introspectType(String)"
INT-->>MB : "{type : 'string'}" for both
MB->>SB : "buildObjectSchema([{name : 'name', schemaMap}, {name : 'email', schemaMap}])"
SB-->>MB : "Schema object with required fields"
MB->>OUT : "Emit tool with inputSchema"
```

**Diagram sources**
- [user_store.dart:55-65](file://example/lib/src/user_store.dart#L55-L65)
- [mcp_builder.dart:229-259](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L229-L259)
- [mcp_builder.dart:442-468](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L442-L468)
- [schema_builder.dart:68-97](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L68-L97)

**Section sources**
- [user_store.dart:55-65](file://example/lib/src/user_store.dart#L55-L65)
- [mcp_builder.dart:229-259](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L229-L259)
- [mcp_builder.dart:442-468](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L442-L468)
- [schema_builder.dart:68-97](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L68-L97)

## Dependency Analysis
External dependencies influencing schema generation:
- analyzer: Provides Dart element and type analysis used by the builder.
- source_gen: Enables source generation and annotation processing.
- code_builder: Used by templates to generate Dart code.
- json_annotation: Supports JSON serialization patterns (referenced in generator pubspec).
- shelf: Used by HTTP template for server scaffolding.

```mermaid
graph LR
PUB_G["generator pubspec.yaml"] --> ANA["analyzer"]
PUB_G --> SG["source_gen"]
PUB_G --> CB["code_builder"]
PUB_G --> JA["json_annotation"]
PUB_G --> SH["shelf"]
PUB_A["annotations pubspec.yaml"] --> META["meta"]
PUB_A --> ANA
```

**Diagram sources**
- [pubspec.yaml:10-18](file://packages/easy_mcp_generator/pubspec.yaml#L10-L18)
- [pubspec.yaml:11-13](file://packages/easy_mcp_annotations/pubspec.yaml#L11-L13)

**Section sources**
- [pubspec.yaml:10-18](file://packages/easy_mcp_generator/pubspec.yaml#L10-L18)
- [pubspec.yaml:11-13](file://packages/easy_mcp_annotations/pubspec.yaml#L11-L13)

## Performance Considerations
- Complexity of introspection scales with the depth and breadth of object graphs. Cycle detection prevents exponential blowup.
- For large schemas, consider minimizing deeply nested structures or flattening where feasible.
- Avoid excessive use of generic collections with unknown inner types to keep schemas precise.
- Keep the number of tools and parameters manageable to reduce build-time overhead.

## Troubleshooting Guide
Common issues and remedies:
- Missing JSON metadata: Ensure the library has @Mcp with generateJson enabled and that the library is processed by the builder.
- Incorrect required fields: Verify parameter and field nullability; optional parameters and nullable fields are not marked required.
- Infinite recursion in schemas: Self-referential types are handled by cycle detection; if unexpected, review type relationships.
- Custom list inner types: For List<T> where T is a custom class, ensure imports are present so the template can convert items using fromJson.

**Section sources**
- [mcp_builder.dart:492-513](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L492-L513)
- [mcp_builder.dart:363-366](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L363-L366)
- [templates.dart:192-207](file://packages/easy_mcp_generator/lib/builder/templates.dart#L192-L207)
- [templates.dart:328-341](file://packages/easy_mcp_generator/lib/builder/templates.dart#L328-L341)

## Conclusion
The JSON Schema generation subsystem provides robust, automated schema construction from Dart types. It supports primitives, generics, nullable types, collections, and custom classes while guarding against cycles. It emits both Dart registration code and a JSON metadata file with schemaVersion and tool definitions, enabling clients to validate inputs and discover capabilities.

## Appendices

### Schema Versioning and Backward Compatibility
- The emitted JSON metadata includes a schemaVersion field. Increment this field when introducing breaking changes to tool signatures or schema structures.
- Maintain backward-compatible additions (new optional fields) to preserve compatibility with older clients.

**Section sources**
- [mcp_builder.dart:467-467](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L467-L467)

### Customization and Extension Patterns
- Customize tool descriptions and icons via @Tool annotations.
- Extend schemas by adding explicit serialization logic in custom classes (e.g., toJson/fromJson) to influence the shape of nested objects.
- For complex nested structures, consider flattening or introducing intermediate DTOs to simplify schemas.

**Section sources**
- [mcp_annotations.dart:58-106](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart#L58-L106)
- [todo.dart:14-28](file://example/lib/src/todo.dart#L14-L28)
- [user.dart:14-28](file://example/lib/src/user.dart#L14-L28)