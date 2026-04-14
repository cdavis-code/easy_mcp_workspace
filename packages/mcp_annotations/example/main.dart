// Example usage of mcp_annotations
import 'package:mcp_annotations/mcp_annotations.dart';

@Mcp()
class MyTools {
  @Tool(description: 'Say hello')
  String greet(String name) {
    return 'Hello, $name!';
  }
}

void main() {
  final tools = MyTools();
  print(tools.greet('World'));
}
