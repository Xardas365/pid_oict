import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/data/models/vehicle_position_dto.dart';

void main() {
  group('VehiclePositionDto', () {
    test('parses vehicle position and converts GeoJSON coordinate order', () {
      final dto = VehiclePositionDto.fromJson({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [14.4378, 50.0755],
        },
        'properties': {
          'vehicle_id': 'tram-22-123',
          'bearing': '87.5',
          'last_updated': '2026-06-22T10:20:00Z',
        },
      });

      expect(dto, isNotNull);
      expect(dto!.vehicleId, 'tram-22-123');
      expect(dto.latitude, 50.0755);
      expect(dto.longitude, 14.4378);
      expect(dto.bearing, 87.5);
      expect(dto.lastUpdated, DateTime.parse('2026-06-22T10:20:00Z'));

      final position = dto.toDomain();

      expect(position.vehicleId, dto.vehicleId);
      expect(position.latitude, dto.latitude);
      expect(position.longitude, dto.longitude);
    });

    test('tolerates missing optional fields and invalid last update', () {
      final dto = VehiclePositionDto.fromJson({
        'geometry': {
          'type': 'Point',
          'coordinates': ['14.4378', '50.0755'],
        },
        'properties': {
          'vehicle_id': 'tram-22-123',
          'last_updated': 'not a date',
        },
      });

      expect(dto, isNotNull);
      expect(dto!.latitude, 50.0755);
      expect(dto.longitude, 14.4378);
      expect(dto.bearing, isNull);
      expect(dto.lastUpdated, isNull);
    });

    test('rejects missing vehicle ID or invalid coordinates', () {
      expect(
        VehiclePositionDto.fromJson({
          'geometry': {
            'type': 'Point',
            'coordinates': [14.4378, 50.0755],
          },
        }),
        isNull,
      );
      expect(
        VehiclePositionDto.fromJson({
          'properties': {'vehicle_id': 'tram-22-123'},
          'geometry': {
            'type': 'Point',
            'coordinates': [200.0, 95.0],
          },
        }),
        isNull,
      );
    });
  });
}
