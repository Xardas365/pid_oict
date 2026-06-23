import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/data/models/departure_dto.dart';

void main() {
  group('DepartureDto parser diagnostics', () {
    test('reports valid departure records', () {
      final result = DepartureDto.parseWithDiagnostics({
        'departures': [
          {
            'route_short_name': '22',
            'headsign': 'Nadrazi Hostivar',
            'departure_time': '2026-06-22T10:15:00Z',
            'departure': {
              'trip': {'id': 'trip-22-123'},
            },
          },
        ],
      });

      expect(result.items, hasLength(1));
      expect(result.items.single.gtfsTripId, 'trip-22-123');
      expect(result.diagnostics.rawCount, 1);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 0);
    });

    test('reports skipped invalid departure records', () {
      final result = DepartureDto.parseWithDiagnostics({
        'departures': [
          {
            'route_short_name': '22',
            'headsign': 'Nadrazi Hostivar',
            'departure_time': '2026-06-22T10:15:00Z',
          },
          {
            'headsign': 'Missing route',
            'departure_time': '2026-06-22T10:15:00Z',
          },
          {'route_short_name': '9', 'departure_time': '2026-06-22T10:15:00Z'},
          {
            'route_short_name': '1',
            'headsign': 'Invalid time',
            'departure_time': 'not-a-date',
          },
        ],
      });

      expect(result.items, hasLength(1));
      expect(result.diagnostics.rawCount, 4);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 3);
      expect(result.diagnostics.skipReasons.map((reason) => reason.reason), [
        'missing route short name',
        'missing headsign',
        'missing or invalid departure time',
      ]);
    });
  });
}
