import 'dart:convert';
import 'dart:io';

Future<Object?> loadJsonFixture(String path) async {
  final source = await File('test/fixtures/$path').readAsString();

  return jsonDecode(source) as Object?;
}
