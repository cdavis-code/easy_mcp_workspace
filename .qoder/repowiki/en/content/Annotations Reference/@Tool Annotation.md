# @Tool Annotation

<cite>
**Referenced Files in This Document**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)
- [example.dart](file://packages/easy_mcp_annotations/test/example.dart)
- [user_store.dart](file://example/lib/src/user_store.dart)
- [todo_store.dart](file://example/lib/src/todo_store.dart)
- [README.md](file://README.md)
</cite>

## Update Summary
**Changes Made**
- Added comprehensive documentation for the new @Parameter annotation system
- Updated @Tool annotation documentation to reflect enhanced parameter metadata extraction capabilities
- Added detailed coverage of parameter metadata including titles, descriptions, examples, validation constraints, and enum values
- Enhanced examples showing practical usage of @Parameter with various validation scenarios
- Updated code generation pipeline integration to include parameter metadata processing

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Enhanced Parameter Metadata System](#enhanced-parameter-metadata-system)
7. [Dependency Analysis](#dependency-analysis)
8. [Performance Considerations](#performance-considerations)
9. [Troubleshooting Guide](#troubleshooting-guide)
10. [Conclusion](#conclusion)
11. [Appendices](#appendices)

## Introduction
This document provides comprehensive guidance for the @Tool annotation used to define MCP tool metadata and enhance documentation. The @Tool annotation now includes enhanced parameter metadata extraction capabilities through the new @Parameter annotation system. It explains how to use the description parameter to override method doc comments, how to specify icons for visual representation, and how the execution parameter is reserved for future use. The documentation covers the new @Parameter annotation system that enables rich parameter metadata including titles, descriptions, examples, validation constraints, and enum values. It also covers the relationship between @Tool and @Mcp annotations, precedence rules, and best practices for integrating @Tool metadata into the code generation pipeline to improve tool discoverability and user experience.

## Project Structure
The @Tool annotation is defined in the annotations package and consumed by the generator package. The generator extracts tool metadata from annotated functions and produces runnable MCP server code and optional JSON metadata. The new @Parameter annotation system enhances parameter metadata extraction with comprehensive validation and presentation capabilities.

```mermaid
graph TB
subgraph "Annotations Package"
A["mcp_annotations.dart<br/>Defines @Mcp, @Tool, and @Parameter"]
end
subgraph "Generator Package"
B["mcp_builder.dart<br/>Extracts tools and metadata"]
C["schema_builder.dart<br/>Builds parameter schemas"]
D["doc_extractor.dart<br/>Doc comment handling"]
end
subgraph "Example"
E["user_store.dart<br/>@Tool with @Parameter usage"]
F["todo_store.dart<br/>Tool implementations"]
end
A --> B
B --> C
B --> D
E --> A
F --> A
```

**Diagram sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)
- [user_store.dart](file://example/lib/src/user_store.dart)
- [todo_store.dart](file://example/lib/src/todo_store.dart)

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)
- [README.md](file://README.md)

## Core Components
- @Tool annotation: Defines tool metadata such as description and icons, and reserves execution for future use.
- @Parameter annotation: **New** Rich parameter metadata including titles, descriptions, examples, validation constraints, and enum values.
- @Mcp annotation: Controls transport mode and optional JSON metadata generation for the server.
- Generator: Extracts tools from annotated functions, resolves descriptions from annotations or doc comments, extracts parameter metadata, and builds server code and optional JSON metadata.

Key behaviors:
- description parameter overrides doc comments when present.
- icons parameter accepts a list of icon URLs for client-side visualization.
- execution parameter is marked as deprecated and reserved for future use.
- **New** @Parameter annotation extracts comprehensive parameter metadata including validation constraints and presentation hints.

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [README.md](file://README.md)

## Architecture Overview
The @Tool annotation integrates with the code generation pipeline as follows:
- The generator scans libraries for @Mcp-annotated code.
- It locates @Tool-annotated functions and extracts their metadata.
- If description is missing, it falls back to the function's doc comment.
- **New** The generator extracts @Parameter annotations from function parameters to build rich parameter schemas.
- The generator produces server code and optionally a JSON metadata file containing tool definitions with enhanced parameter metadata.

```mermaid
sequenceDiagram
participant Dev as "Developer"
participant Gen as "McpBuilder"
participant Param as "Parameter Extractor"
participant Ann as "@Tool/@Parameter/@Mcp annotations"
participant Out as "Generated Artifacts"
Dev->>Ann : Apply @Mcp, @Tool, and @Parameter to functions
Dev->>Gen : Run build_runner
Gen->>Ann : Inspect library for @Mcp
Gen->>Ann : Find @Tool-annotated functions
Gen->>Ann : Extract @Parameter metadata from parameters
Gen->>Param : Process parameter metadata (titles, validation, examples)
Param->>Gen : Return enriched parameter schemas
Gen->>Gen : Resolve description (annotation or doc comment)
Gen->>Out : Generate .mcp.dart server code
Gen->>Out : Optionally generate .mcp.json metadata with parameter schemas
```

**Diagram sources**
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)

## Detailed Component Analysis

### @Tool Annotation Definition and Behavior
The @Tool annotation supports three parameters:
- description: Overrides the function's doc comment for the tool description.
- icons: A list of icon URLs for client-side visualization.
- execution: Reserved for future use; currently deprecated.

Behavior highlights:
- If description is provided, it takes precedence over doc comments.
- If description is omitted, the generator uses the function's doc comment.
- Icons are not processed by the generator in this implementation; they are part of the tool metadata model.
- The execution parameter is deprecated and currently ignored.

```mermaid
classDiagram
class Tool {
+String? description
+String[]? icons
+Map~String, Object~~? execution
}
class Parameter {
+String? title
+String? description
+Object? example
+num? minimum
+num? maximum
+String? pattern
+bool sensitive
+Object[]~? enumValues
}
class Mcp {
+McpTransport transport
+bool generateJson
}
Tool <.. Mcp : "used together"
Parameter ..> Tool : "enhances parameter metadata"
```

**Diagram sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)

### Description Resolution: Annotation vs Doc Comments
The generator resolves the tool description in this order:
1. Use @Tool.description if present.
2. Otherwise, fall back to the function's doc comment.
3. If neither is available, a default description is applied.

```mermaid
flowchart TD
Start(["Resolve Tool Description"]) --> CheckAnnotation["Check @Tool.description"]
CheckAnnotation --> HasAnnotation{"Description provided?"}
HasAnnotation --> |Yes| UseAnnotation["Use @Tool.description"]
HasAnnotation --> |No| CheckDoc["Check function doc comment"]
CheckDoc --> HasDoc{"Doc comment present?"}
HasDoc --> |Yes| UseDoc["Use doc comment"]
HasDoc --> |No| UseDefault["Use default description"]
UseAnnotation --> End(["Resolved"])
UseDoc --> End
UseDefault --> End
```

**Diagram sources**
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)

**Section sources**
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [README.md](file://README.md)

### Icon Specification Guidelines
- Provide a list of icon URLs via the icons parameter.
- Clients may render these icons to improve tool discoverability.
- The generator does not validate or process icon URLs; ensure they are publicly accessible and appropriate for client environments.

Best practices:
- Prefer HTTPS URLs for icons.
- Keep icon sizes reasonable for UI rendering.
- Provide multiple resolutions if needed by clients.

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)

### Execution Parameter: Deprecation and Future Compatibility
- The execution parameter is deprecated and reserved for future use.
- Current behavior: Ignored by the generator.
- Future compatibility: Expect execution-related metadata to be supported in upcoming versions.

Recommendations:
- Avoid relying on execution in current implementations.
- Plan for future updates by noting the deprecation notice.

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)

### Relationship Between @Tool and @Mcp Annotations
- @Mcp controls transport mode and optional JSON metadata generation.
- @Tool annotates functions as tools and supplies metadata.
- Together, they enable the generator to produce runnable servers and optional JSON metadata.

Precedence and inheritance rules:
- @Mcp determines whether the generator runs and whether JSON metadata is produced.
- @Tool applies per annotated function; it does not inherit from @Mcp.
- Description resolution prioritizes @Tool.description over doc comments.

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [README.md](file://README.md)

### Practical Examples and Usage Patterns
Examples demonstrate typical @Tool usage patterns:
- Basic description override.
- Icon specification for visual representation.
- Deprecated execution parameter usage (for testing deprecation warnings).
- **New** Comprehensive @Parameter usage with validation constraints and examples.

These examples are available in the annotations test suite and the example project, serving as reference for correct usage.

**Section sources**
- [example.dart](file://packages/easy_mcp_annotations/test/example.dart)
- [user_store.dart](file://example/lib/src/user_store.dart)
- [todo_store.dart](file://example/lib/src/todo_store.dart)

### Code Generation Pipeline Integration
The generator performs the following steps:
- Scans libraries for @Mcp annotations.
- Extracts @Tool-annotated functions and metadata.
- Resolves descriptions from annotations or doc comments.
- **New** Extracts @Parameter annotations from function parameters to build rich parameter schemas.
- Produces server code and optionally JSON metadata.

```mermaid
sequenceDiagram
participant Lib as "Library with @Mcp/@Tool/@Parameter"
participant Gen as "McpBuilder"
participant Param as "Parameter Extractor"
participant Meta as "Metadata"
participant Art as "Artifacts"
Lib->>Gen : Library with @Mcp
Gen->>Lib : Find @Tool-annotated functions
Gen->>Param : Extract @Parameter metadata from parameters
Param->>Gen : Return enriched parameter schemas
Gen->>Meta : Resolve description and parameters
Gen->>Art : Write .mcp.dart
Gen->>Art : Optionally write .mcp.json
```

**Diagram sources**
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)

**Section sources**
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)

## Enhanced Parameter Metadata System

### @Parameter Annotation Definition and Capabilities
The @Parameter annotation provides comprehensive parameter metadata extraction:

**Core Parameters:**
- title: Human-readable title displayed in MCP clients.
- description: Detailed explanation of the parameter's purpose.
- example: Example value to guide users.
- minimum/maximum: Numeric validation bounds.
- pattern: Regular expression pattern for string validation.
- sensitive: Whether parameter contains sensitive data.
- enumValues: List of allowed values for enum-like parameters.

**Advanced Features:**
- **Validation Constraints**: Automatic validation for numeric ranges and string patterns.
- **Presentation Hints**: Titles and descriptions for improved user experience.
- **Security Awareness**: Sensitive parameter marking for masking in logs and UI.
- **Enum Support**: Restricted value sets for controlled parameter inputs.

**Section sources**
- [mcp_annotations.dart:142-240](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart#L142-L240)

### Parameter Metadata Extraction Process
The generator extracts @Parameter metadata through a comprehensive extraction process:

```mermaid
flowchart TD
Start(["Extract Parameter Metadata"]) --> FindParam["@Parameter annotation on parameter"]
FindParam --> ExtractFields["Extract all metadata fields"]
ExtractFields --> ValidateTypes["Validate data types"]
ValidateTypes --> BuildSchema["Build parameter schema"]
BuildSchema --> ApplyConstraints["Apply validation constraints"]
ApplyConstraints --> EnhancePresentation["Enhance presentation metadata"]
EnhancePresentation --> ReturnMetadata["Return enriched metadata"]
```

**Diagram sources**
- [mcp_builder.dart:285-369](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L285-L369)

**Section sources**
- [mcp_builder.dart:243-369](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart#L243-L369)

### Schema Builder Integration
The SchemaBuilder transforms extracted parameter metadata into executable Dart code:

**Supported Transformations:**
- Primitive types: String, int, double, bool with metadata enhancement.
- Complex types: Objects and arrays with recursive metadata application.
- Validation constraints: Automatic generation of validation rules.
- Presentation enhancements: Titles, descriptions, and examples.

**Section sources**
- [schema_builder.dart:1-199](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart#L1-L199)

### Practical Parameter Metadata Examples
**Basic Parameter Enhancement:**
```dart
@Tool(description: 'Create a new user')
Future<User> createUser({
  @Parameter(
    title: 'Full Name',
    description: 'The user\'s complete name',
    example: 'John Doe',
  )
  required String name,
})
```

**Advanced Validation:**
```dart
@Tool(description: 'Process payment')
Future<Payment> processPayment({
  @Parameter(
    title: 'Amount',
    description: 'Payment amount in USD',
    minimum: 0.01,
    maximum: 999999.99,
    example: 99.99,
  )
  required double amount,
  
  @Parameter(
    title: 'Card Number',
    description: 'Credit card number',
    pattern: r'^\d{16}$',
    sensitive: true,
  )
  required String cardNumber,
})
```

**Section sources**
- [user_store.dart:52-72](file://example/lib/src/user_store.dart#L52-L72)
- [user_store.dart:138-156](file://example/lib/src/user_store.dart#L138-L156)

## Dependency Analysis
- @Tool depends on the generator to extract and process metadata.
- @Parameter provides enhanced metadata extraction capabilities.
- @Mcp controls the generator's behavior and output format.
- Doc comment extraction is handled by the generator's documentation extractor.
- **New** Parameter metadata extraction is handled by dedicated parameter extraction logic.

```mermaid
graph LR
Tool["@Tool"] --> Builder["McpBuilder"]
Parameter["@Parameter"] --> Builder
Mcp["@Mcp"] --> Builder
Builder --> DocExt["DocExtractor"]
Builder --> ParamExtractor["Parameter Extractor"]
Builder --> SchemaBuilder["SchemaBuilder"]
Builder --> Artifacts["Generated Artifacts"]
```

**Diagram sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [schema_builder.dart](file://packages/easy_mcp_generator/lib/builder/schema_builder.dart)

## Performance Considerations
- Doc comment parsing is straightforward; keep descriptions concise for readability.
- Avoid excessive icon URLs to minimize metadata size.
- Prefer minimal execution metadata until the feature is implemented.
- **New** Parameter metadata extraction adds minimal overhead during compilation.
- **New** Schema building is optimized for common parameter patterns.

## Troubleshooting Guide
Common issues and resolutions:
- Missing description: Ensure either @Tool.description is provided or the function has a doc comment.
- Deprecated execution warning: Remove or avoid setting execution until supported.
- Icons not rendering: Verify icon URLs are accessible and appropriate for client environments.
- **New** Parameter metadata not appearing: Ensure @Parameter annotation is properly placed on function parameters.
- **New** Validation errors: Verify parameter constraints match expected input ranges and formats.
- **New** Schema generation issues: Check that parameter types are properly inferred and supported.

**Section sources**
- [mcp_annotations.dart](file://packages/easy_mcp_annotations/lib/mcp_annotations.dart)
- [mcp_builder.dart](file://packages/easy_mcp_generator/lib/builder/mcp_builder.dart)
- [example.dart](file://packages/easy_mcp_annotations/test/example.dart)

## Conclusion
The @Tool annotation enables precise tool metadata definition for MCP servers. With the introduction of the @Parameter annotation system, developers can now provide comprehensive parameter metadata including validation constraints, presentation hints, and security considerations. By combining @Tool with @Parameter and @Mcp, developers can produce discoverable, well-documented tools with rich parameter schemas and optional JSON metadata. While the execution parameter is reserved for future use, description and icon specifications, along with the new parameter metadata system, provide immediate value for user experience and tool presentation.

## Appendices

### Best Practices for Tool Documentation
- Write clear, concise descriptions that explain the tool's purpose and outcomes.
- Use doc comments when no @Tool.description is provided; ensure they are well-formatted.
- Provide meaningful icons to aid quick recognition in client UIs.
- **New** Use @Parameter annotations to enhance parameter usability and validation.

### Icon Specification Guidelines
- Use HTTPS URLs for icons.
- Keep icon sizes optimized for UI rendering.
- Provide multiple resolutions if needed by clients.

### Proper Description Formatting
- Start descriptions with a verb describing the action performed.
- Include expected inputs and outputs briefly if helpful.
- Avoid overly technical jargon when targeting diverse audiences.

### **New** Parameter Metadata Best Practices
- **Clarity**: Use descriptive titles and detailed descriptions for complex parameters.
- **Validation**: Implement appropriate constraints (minimum/maximum, patterns) to prevent invalid inputs.
- **Examples**: Provide realistic examples that demonstrate expected input formats.
- **Security**: Mark sensitive parameters (passwords, API keys) as sensitive.
- **Enums**: Use enumValues for controlled inputs like status codes or categories.
- **Consistency**: Maintain consistent naming conventions across related parameters.

### **New** Advanced Parameter Validation Examples
**Numeric Validation:**
```dart
@Parameter(
  title: 'Age',
  description: 'User age in years',
  minimum: 0,
  maximum: 150,
  example: 25,
)
int? age,
```

**String Pattern Validation:**
```dart
@Parameter(
  title: 'Email',
  description: 'Valid email address',
  pattern: r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  example: 'user@example.com',
)
required String email,
```

**Section sources**
- [README.md](file://README.md)
- [user_store.dart:52-72](file://example/lib/src/user_store.dart#L52-L72)
- [user_store.dart:138-156](file://example/lib/src/user_store.dart#L138-L156)