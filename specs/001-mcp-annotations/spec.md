# Feature Specification: MCP Annotations Library

**Feature Branch**: `001-mcp-annotations`  
**Created**: 2026-04-12  
**Status**: Draft  
**Input**: User description: "1️⃣ Create annotation library `mcp_annotations` exposing @mcp(transport) and @tool(description?, icons?, execution?) with proper Dart doc‑comment extraction."

## Clarifications

### Session 2026-04-12

- Q: What transport types should be supported by the `@mcp` annotation? → A: Support stdio and http transports
- Q: What format should be supported for tool icons? → A: Support HTTPS URLs only
- Q: How should execution metadata be structured in the `@tool` annotation? → A: Ignore this attribute for now, we will implement it in the future
- Q: How should multiline doc comments be processed for tool descriptions? → A: Join lines with spaces
- Q: What should happen when invalid parameter values are provided to the annotations? → A: Fail at compile time with clear error messages

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Define MCP Annotations (Priority: P1)

As a Dart developer, I want to annotate my library methods with `@mcp` and `@tool` so that they can be exposed as tools in an MCP server.

**Why this priority**: This is the core functionality of the feature - without these annotations, there's no way to mark methods for MCP exposure.

**Independent Test**: Can be fully tested by creating a simple Dart file with annotated methods and verifying the annotations exist and have the correct parameters.

**Acceptance Scenarios**:

1. **Given** a Dart method, **When** I add `@mcp()` annotation, **Then** it should accept a `transport` parameter with default value 'stdio'
2. **Given** a Dart method, **When** I add `@tool()` annotation, **Then** it should accept optional parameters: `description`, `icons`, and `execution`

---

### User Story 2 - Extract Documentation Comments (Priority: P2)

As a Dart developer, I want the tool description to be automatically extracted from my method's doc comments when I don't provide an explicit description.

**Why this priority**: Improves developer experience by reducing boilerplate while maintaining flexibility.

**Independent Test**: Can be tested by creating methods with and without doc comments and checking that the generated tool descriptions match expectations.

**Acceptance Scenarios**:

1. **Given** a method with doc comments, **When** no explicit `description` is provided in `@tool`, **Then** the doc comments should be used as the tool description
2. **Given** a method without doc comments, **When** no explicit `description` is provided, **Then** a default description should be used

---

### User Story 3 - Handle All Annotation Parameters (Priority: P3)

As a Dart developer, I want to be able to specify all optional parameters in the `@tool` annotation so that I can fully customize my MCP tools.

**Why this priority**: Enables full customization of the generated tools without being blocking for basic functionality.

**Independent Test**: Can be tested by creating annotations with various combinations of parameters and verifying they're correctly preserved.

**Acceptance Scenarios**:

1. **Given** a `@tool` annotation, **When** I specify `icons` parameter, **Then** those icons should be available in the generated tool metadata
2. **Given** a `@tool` annotation, **When** I specify `execution` parameter, **Then** that metadata should be available in the generated tool metadata

---

### Edge Cases

- What happens when a method has both doc comments and an explicit description in `@tool`?
- How does the system handle multiline doc comments? (Join lines with spaces)
- What happens when invalid parameter values are provided to the annotations? (Fail at compile time with clear error messages)
- What happens when `execution` parameter is provided? (Ignore for now as it will be implemented in the future)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide `@mcp` annotation with optional `transport` parameter (default: 'stdio', supported values: 'stdio', 'http')
- **FR-002**: System MUST provide `@tool` annotation with optional `description`, `icons`, and `execution` parameters
- **FR-003**: System MUST extract method doc comments and use them as tool descriptions when `@tool.description` is not provided (multiline comments joined with spaces)
- **FR-004**: System MUST handle methods with no doc comments gracefully (use default description)
- **FR-005**: System MUST preserve all `@tool` metadata (icons as HTTPS URLs) in the generated code
- **FR-006**: Annotations MUST be usable on any top-level function or class method
- **FR-007**: Annotations MUST be `const` so they can be used in const contexts
- **FR-008**: System MUST validate annotation parameters at compile time and provide clear error messages for invalid values
- **FR-009**: System MUST ignore `execution` parameter for now as it will be implemented in the future

### Key Entities *(include if feature involves data)*

- **mcp Annotation**: Marks a method for MCP exposure; specifies transport type
- **tool Annotation**: Describes an MCP tool; contains description, icons, and execution metadata
- **Annotated Element**: Dart method or function annotated with the above; source of tool name and parameters

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of annotated methods are correctly recognized by the generator
- **SC-002**: 95% of doc comments are correctly extracted and used as tool descriptions
- **SC-003**: All `@tool` metadata (icons, execution) is preserved in the generated code
- **SC-004**: Generated code compiles without errors in a standard Dart environment

## Assumptions

- Developers are familiar with Dart annotations and have existing methods to annotate
- The generator will be run via `build_runner` in a standard Dart project
- Doc comments follow standard Dart format (///)
- Icons are represented as HTTPS URLs only
- Execution metadata will be ignored for now as it will be implemented in the future
- Invalid annotation parameters will cause compile-time failures with clear error messages