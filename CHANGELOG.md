# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-04-12

### Added
- `mcp_annotations` package with:
  - `@mcp` annotation with `transport` parameter (stdio/http)
  - `@tool` annotation with optional `description`, `icons`, `execution` parameters
  - `McpTransport` enum for type-safe transport selection
- `mcp_generator` package with:
  - Stub builder for code generation
  - DocExtractor for doc comment parsing
  - JSON-Schema generation
  - StdioTemplate and HttpTemplate for server generation
- Specification files under `specs/001-mcp-annotations/`
- Complete task list for implementation

### Known Limitations
- Generator uses stub implementations; full `build_runner` integration pending
- `execution` parameter on `@tool` is deprecated (future feature)
- Icons are stored but not validated for HTTPS URLs in this version