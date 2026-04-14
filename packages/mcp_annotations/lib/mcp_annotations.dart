// MCP annotations package
//
// Provides annotations used to expose library methods as tools in the
// Model Context Protocol (MCP) server.

enum McpTransport {
  /// Communicate via standard input/output (JSON-RPC).
  stdio,

  /// Run an HTTP server using shelf.
  http,
}

/// Annotation to mark a class, library, or method for MCP exposure.
///
/// Currently only the `transport` named parameter is used. It tells the
/// generator which transport to generate for the annotated method.
///
/// Example:
/// ```dart
/// @Mcp(transport: McpTransport.stdio)
/// @Tool(description: 'Create users')
/// Future<bool> createUsers(List<User> users) async { ... }
/// ```
class Mcp {
  final McpTransport transport;
  final bool generateJson;

  const Mcp({this.transport = McpTransport.stdio, this.generateJson = false});
}

/// Annotation that describes an MCP tool.
///
/// * `description` – Optional text to override the method's doc comment.
/// * `icons` – Optional list of icon URLs.
/// * `execution` – **DEPRECATED** - This parameter is reserved for future
///   use and will be implemented in a later version.
class Tool {
  final String? description;
  final List<String>? icons;

  /// Deprecated: Execution metadata will be supported in a future version.
  /// Currently ignored.
  @Deprecated('Will be implemented in future version')
  final Map<String, Object?>? execution;

  const Tool({this.description, this.icons, this.execution});
}
