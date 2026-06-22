import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/data/vehicle_position_repository.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('VehiclePositionRepository', () {
    test('loads the first valid vehicle position', () async {
      final apiClient = FakeGolemioApiClient(
        response: {
          'features': [
            {
              'properties': {'vehicle_id': 'missing-coordinates'},
            },
            {
              'geometry': {
                'type': 'Point',
                'coordinates': [14.4378, 50.0755],
              },
              'properties': {
                'vehicle_id': 'tram-22-123',
                'bearing': 87.5,
                'last_updated': '2026-06-22T10:20:00Z',
              },
            },
          ],
        },
      );
      final repository = VehiclePositionRepository(apiClient);

      final position = await repository.fetchVehiclePosition('tram-22-123');

      expect(apiClient.calls, hasLength(1));
      expect(
        apiClient.calls.single.path,
        '/v2/public/vehiclepositions/tram-22-123',
      );
      expect(position.vehicleId, 'tram-22-123');
      expect(position.latitude, 50.0755);
      expect(position.longitude, 14.4378);
      expect(position.bearing, 87.5);
    });

    test('encodes vehicle ID as one path segment', () async {
      final apiClient = FakeGolemioApiClient(
        response: {
          'geometry': {
            'type': 'Point',
            'coordinates': [14.4378, 50.0755],
          },
          'properties': {'vehicle_id': 'vehicle/with slash'},
        },
      );
      final repository = VehiclePositionRepository(apiClient);

      await repository.fetchVehiclePosition('vehicle/with slash');

      expect(
        apiClient.calls.single.path,
        '/v2/public/vehiclepositions/vehicle%2Fwith%20slash',
      );
    });

    test('throws controlled error when vehicle ID is blank', () async {
      final repository = VehiclePositionRepository(
        FakeGolemioApiClient(response: null),
      );

      await expectLater(
        repository.fetchVehiclePosition('  '),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.invalidData,
          ),
        ),
      );
    });

    test(
      'throws controlled error when no valid position is returned',
      () async {
        final repository = VehiclePositionRepository(
          FakeGolemioApiClient(
            response: {
              'features': [
                {
                  'properties': {'vehicle_id': 'missing-coordinates'},
                },
              ],
            },
          ),
        );

        await expectLater(
          repository.fetchVehiclePosition('tram-22-123'),
          throwsA(
            isA<AppException>().having(
              (error) => error.type,
              'type',
              AppExceptionType.invalidData,
            ),
          ),
        );
      },
    );
  });
}
