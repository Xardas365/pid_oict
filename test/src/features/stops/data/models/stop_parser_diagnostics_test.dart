import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/models/stop_dto.dart';

void main() {
  group('StopDto parser diagnostics', () {
    test('reports all valid records', () {
      final result = StopDto.parseWithDiagnostics({
        'features': [
          {
            'properties': {
              'stop_id': 'U1',
              'stop_name': 'Andel',
              'platform_code': 'A',
            },
          },
          {
            'properties': {'stop_id': 'U2', 'stop_name': 'Staromestska'},
          },
        ],
      });

      expect(result.items, hasLength(2));
      expect(result.diagnostics.rawCount, 2);
      expect(result.diagnostics.parsedCount, 2);
      expect(result.diagnostics.skippedCount, 0);
      expect(result.diagnostics.skipReasons, isEmpty);
    });

    test('reports partially invalid records', () {
      final result = StopDto.parseWithDiagnostics({
        'features': [
          {
            'properties': {'stop_id': 'U1', 'stop_name': 'Andel'},
          },
          {
            'properties': {'stop_name': 'Missing id'},
          },
          {
            'properties': {'stop_id': 'missing-name'},
          },
        ],
      });

      expect(result.items, hasLength(1));
      expect(result.diagnostics.rawCount, 3);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 2);
      expect(result.diagnostics.skipReasons.map((reason) => reason.reason), [
        'missing required stop id',
        'missing display name',
      ]);
    });
  });
}
