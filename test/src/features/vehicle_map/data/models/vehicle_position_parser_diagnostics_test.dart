import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/data/models/vehicle_position_dto.dart';

void main() {
  group('VehiclePositionDto parser diagnostics', () {
    test('reports a valid vehicle position', () {
      final result = VehiclePositionDto.parseWithDiagnostics({
        'features': [
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [14.4378, 50.0755],
            },
            'properties': {'vehicle_id': 'vehicle-123'},
          },
        ],
      });

      expect(result.items, hasLength(1));
      expect(result.items.single.latitude, 50.0755);
      expect(result.items.single.longitude, 14.4378);
      expect(result.diagnostics.rawCount, 1);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 0);
    });

    test('reports no usable vehicle position', () {
      final result = VehiclePositionDto.parseWithDiagnostics({
        'features': [
          {
            'properties': {'vehicle_id': 'missing-coordinates'},
          },
          {
            'geometry': {
              'type': 'Point',
              'coordinates': [999, 999],
            },
            'properties': {'vehicle_id': 'invalid-coordinates'},
          },
        ],
      });

      expect(result.items, isEmpty);
      expect(result.diagnostics.rawCount, 2);
      expect(result.diagnostics.parsedCount, 0);
      expect(result.diagnostics.skippedCount, 2);
      expect(result.diagnostics.skipReasons.map((reason) => reason.reason), [
        'missing coordinates',
        'invalid coordinate shape',
      ]);
    });
  });
}
