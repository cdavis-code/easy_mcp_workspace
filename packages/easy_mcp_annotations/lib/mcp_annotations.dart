/// MCP annotations package
///
/// Provides annotations used to expose library methods as tools in the
/// Model Context Protocol (MCP) server.
library;

/// Transport protocol options for MCP servers.
///
/// Determines how the generated MCP server will communicate with clients.
enum McpTransport {
  /// Communicate via standard input/output using JSON-RPC protocol.
  ///
  /// This is the default transport and is suitable for CLI-based MCP clients.
  stdio,

  /// Run an HTTP server using the shelf package.
  ///
  /// This transport allows remote clients to connect via HTTP requests.
  http,
}

/// Annotation to mark a class, library, or method for MCP exposure.
///
/// Use this annotation to configure how the MCP server will be generated
/// for the annotated element. The generator uses these settings to create
/// the appropriate server transport and behavior.
///
/// The [transport] parameter determines whether the server uses stdio
/// (for CLI integration) or HTTP (for network access).
///
/// The [generateJson] parameter controls whether the generator should
/// also produce a JSON metadata file alongside the Dart code.
///
/// The [port] parameter specifies the port number for HTTP transport.
/// Only used when [transport] is [McpTransport.http]. Defaults to 3000.
///
/// The [address] parameter specifies the bind address for HTTP transport.
/// Only used when [transport] is [McpTransport.http].
/// Defaults to 'localhost'. Use '0.0.0.0' to listen on all interfaces.
///
/// Example:
/// ```dart
/// @Mcp(transport: McpTransport.stdio)
/// @Tool(description: 'Create users')
/// Future<bool> createUsers(List<User> users) async { ... }
/// ```
///
/// Example with HTTP transport:
/// ```dart
/// @Mcp(transport: McpTransport.http, port: 8080, address: '0.0.0.0')
/// @Tool(description: 'Create users')
/// Future<bool> createUsers(List<User> users) async { ... }
/// ```
class Mcp {
  /// The transport protocol used by the generated MCP server.
  ///
  /// Defaults to [McpTransport.stdio] for command-line integration.
  final McpTransport transport;

  /// Whether to generate a JSON metadata file in addition to Dart code.
  ///
  /// When true, the generator will create a `.mcp.json` file containing
  /// tool metadata and schema definitions.
  final bool generateJson;

  /// The port number for HTTP transport.
  ///
  /// Only used when [transport] is [McpTransport.http].
  /// Defaults to 3000.
  final int port;

  /// The bind address for HTTP transport.
  ///
  /// Only used when [transport] is [McpTransport.http].
  /// Defaults to '127.0.0.1' (loopback). Use '0.0.0.0' to listen on all interfaces.
  final String address;

  /// Creates an MCP configuration annotation.
  ///
  /// [transport] determines the communication protocol (stdio or HTTP).
  /// [generateJson] controls whether to generate additional JSON metadata.
  /// [port] specifies the HTTP server port (default: 3000).
  /// [address] specifies the HTTP bind address (default: '127.0.0.1').
  const Mcp({
    this.transport = McpTransport.stdio,
    this.generateJson = false,
    this.port = 3000,
    this.address = '127.0.0.1',
  });
}

/// Annotation that describes an MCP tool.
///
/// Apply this annotation to methods that should be exposed as tools
/// in the generated MCP server. Each tool becomes callable by MCP clients.
///
/// The [description] provides a human-readable explanation of what
/// the tool does. If not provided, the generator will use the method's
/// dartdoc comment.
///
/// The [icons] parameter allows specifying icon URLs for UI clients
/// that display available tools.
///
/// Example:
/// ```dart
/// @Tool(
///   description: 'Creates a new user in the system',
///   icons: ['https://example.com/user-icon.png'],
/// )
/// Future<User> createUser({required String name, required String email}) async {
///   // Implementation
/// }
/// ```
class Tool {
  /// Optional text describing what this tool does.
  ///
  /// If not provided, the generator will use the method's dartdoc comment.
  /// This description is shown to users in MCP clients.
  final String? description;

  /// Optional list of icon URLs for this tool.
  ///
  /// These icons may be displayed by MCP clients to visually identify
  /// the tool. Supported formats depend on the client.
  final List<String>? icons;

  /// Deprecated: Execution metadata will be supported in a future version.
  ///
  /// Currently ignored. Reserved for future use to specify execution
  /// parameters like timeouts and resource limits.
  @Deprecated('Will be implemented in future version')
  final Map<String, Object?>? execution;

  /// Creates a Tool annotation.
  ///
  /// [description] - Human-readable description of the tool's purpose.
  /// [icons] - Optional list of icon URLs for visual identification.
  /// [execution] - Deprecated, will be implemented in a future version.
  const Tool({this.description, this.icons, this.execution});
}
