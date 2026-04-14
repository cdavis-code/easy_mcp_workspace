import 'package:mcp_annotations/mcp_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('@mcp annotation', () {
    test('accepts stdio transport parameter', () {
      final annotation = Mcp(transport: McpTransport.stdio);
      expect(annotation.transport, McpTransport.stdio);
    });

    test('accepts http transport parameter', () {
      final annotation = Mcp(transport: McpTransport.http);
      expect(annotation.transport, McpTransport.http);
    });

    test('defaults to stdio transport', () {
      final annotation = Mcp();
      expect(annotation.transport, McpTransport.stdio);
    });
  });
}
