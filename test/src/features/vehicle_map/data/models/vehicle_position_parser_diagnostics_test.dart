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

    test('uses fallback vehicle ID for Swagger public response', () {
      final result = VehiclePositionDto.parseWithDiagnostics({
        'geometry': {
          'type': 'Point',
          'coordinates': [14.441252, 50.109318],
        },
        'bearing': 45,
        'origin_timestamp': '2023-12-06T12:00:00+01:00',
      }, fallbackVehicleId: 'service-3-1001');

      expect(result.items, hasLength(1));
      expect(result.items.single.vehicleId, 'service-3-1001');
      expect(result.items.single.latitude, 50.109318);
      expect(result.items.single.longitude, 14.441252);
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
