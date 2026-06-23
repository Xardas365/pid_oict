import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/shared/utils/json_parsing.dart';
import 'package:pid_oict/src/shared/utils/parser_diagnostics.dart';

void main() {
  group('parseJsonRecordsWithDiagnostics', () {
    test('caps representative skip reasons', () {
      final response = List<JsonMap>.generate(
        10,
        (index) => {'id': index.toString()},
      );

      final result = parseJsonRecordsWithDiagnostics<String>(
        response: response,
        parse: (_) => null,
        skipReason: (_) => 'missing required field',
        maxSkipReasons: 3,
      );

      expect(result.items, isEmpty);
      expect(result.diagnostics.rawCount, 10);
      expect(result.diagnostics.parsedCount, 0);
      expect(result.diagnostics.skippedCount, 10);
      expect(result.diagnostics.skipReasons, hasLength(3));
      expect(result.diagnostics.skipReasons.map((reason) => reason.index), [
        0,
        1,
        2,
      ]);
    });
  });
}
