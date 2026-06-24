import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/data/models/vehicle_position_dto.dart';

void main() {
  group('VehiclePositionDto', () {
    test('parses vehicle position and converts GeoJSON coordinate order', () {
      final dto = VehiclePositionDto.fromJson({
        'gtfs_trip_id': '115_107_180501',
        'route_type': 'bus',
        'route_short_name': '22',
        'trip_headsign': 'Bila Hora',
        'geometry': {
          'type': 'Point',
          'coordinates': [14.441252, 50.109318],
        },
        'vehicle_id': 'service-3-1001',
        'bearing': 45,
        'origin_timestamp': '2023-12-06T12:00:00+01:00',
      });

      expect(dto, isNotNull);
      expect(dto!.vehicleId, 'service-3-1001');
      expect(dto.latitude, 50.109318);
      expect(dto.longitude, 14.441252);
      expect(dto.bearing, 45);
      expect(dto.lastUpdated, DateTime.parse('2023-12-06T12:00:00+01:00'));

      final position = dto.toDomain();

      expect(position.vehicleId, dto.vehicleId);
      expect(position.latitude, dto.latitude);
      expect(position.longitude, dto.longitude);
    });

    test('uses fallback vehicle ID when response omits vehicle ID', () {
      final dto = VehiclePositionDto.fromJson({
        'geometry': {
          'type': 'Point',
          'coordinates': [14.441252, 50.109318],
        },
      }, fallbackVehicleId: 'service-3-1001');

      expect(dto, isNotNull);
      expect(dto!.vehicleId, 'service-3-1001');
      expect(dto.latitude, 50.109318);
      expect(dto.longitude, 14.441252);
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
