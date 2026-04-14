// Test script to verify the MCP server works correctly.
// Run: dart run test_mcp.dart
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Starting MCP server test...\n');

  final process = await Process.start('dart', ['run', 'lib/src/user.mcp.dart']);

  // Listen to stdout
  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      if (line.isNotEmpty) {
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          print(
            'Response: ${const JsonEncoder.withIndent('  ').convert(json)}',
          );
        } catch (_) {
          print('Raw: $line');
        }
      }
    },
  );

  // Listen to stderr
  process.stderr.transform(utf8.decoder).listen((line) {
    if (line.isNotEmpty) print('Server stderr: $line');
  });

  // Helper to send requests
  Future<void> sendRequest(Map<String, dynamic> request) async {
    final json = jsonEncode(request);
    print('\nSending: $json');
    process.stdin.writeln(json);
    // Give the server time to process
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Test 1: Initialize
  await sendRequest({
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': {},
      'clientInfo': {'name': 'test', 'version': '1.0'},
    },
  });

  // Test 2: List tools
  await sendRequest({
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/list',
    'params': {},
  });

  // Test 3: Call listUsers
  await sendRequest({
    'jsonrpc': '2.0',
    'id': 3,
    'method': 'tools/call',
    'params': {'name': 'listUsers', 'arguments': {}},
  });

  // Test 4: Call createUser
  await sendRequest({
    'jsonrpc': '2.0',
    'id': 4,
    'method': 'tools/call',
    'params': {
      'name': 'createUser',
      'arguments': {'name': 'Test User', 'email': 'test@example.com'},
    },
  });

  // Test 5: Call searchUsers
  await sendRequest({
    'jsonrpc': '2.0',
    'id': 5,
    'method': 'tools/call',
    'params': {
      'name': 'searchUsers',
      'arguments': {'query': 'Test'},
    },
  });

  // Wait for all responses
  await Future.delayed(const Duration(seconds: 2));

  // Clean up
  await process.stdin.close();
  await process.exitCode;

  print('\nAll tests completed!');
}
