// Example: Using mcp_generator with build_runner
//
// 1. Add mcp_annotations and mcp_generator to your pubspec.yaml
// 2. An annotate your methods with @Mcp() and @Tool()
// 3. Run: dart run build_runner build
//
// See the mcp_annotations package for annotation usage.

import 'package:mcp_annotations/mcp_annotations.dart';

@Mcp()
class ExampleTools {
  @Tool(description: 'Add two numbers')
  int add(int a, int b) => a + b;

  @Tool(description: 'Get current timestamp')
  String now() => DateTime.now().toIso8601String();
}

void main() {
  final tools = ExampleTools();
  print('add(2, 3) = ${tools.add(2, 3)}');
  print('now() = ${tools.now()}');
}
