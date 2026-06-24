import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/data/repositories/golemio_vehicle_position_repository.dart';

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
      final repository = GolemioVehiclePositionRepository(apiClient);

      final position = await repository.fetchVehiclePosition('service-3-1001');

      expect(apiClient.calls, hasLength(1));
      expect(
        apiClient.calls.single.path,
        '/v2/public/vehiclepositions/service-3-1001',
      );
      expect(apiClient.calls.single.queryParameters, {'scopes': 'info'});
      expect(position.vehicleId, 'tram-22-123');
      expect(position.latitude, 50.0755);
      expect(position.longitude, 14.4378);
      expect(position.bearing, 87.5);
    });

    test('encodes vehicleId as one path segment', () async {
      final apiClient = FakeGolemioApiClient(
        response: {
          'geometry': {
            'type': 'Point',
            'coordinates': [14.4378, 50.0755],
          },
          'properties': {'vehicle_id': 'vehicle/with slash'},
        },
      );
      final repository = GolemioVehiclePositionRepository(apiClient);

      await repository.fetchVehiclePosition('service/with slash');

      expect(
        apiClient.calls.single.path,
        '/v2/public/vehiclepositions/service%2Fwith%20slash',
      );
    });

    test(
      'uses request vehicleId when response body omits vehicle id',
      () async {
        final apiClient = FakeGolemioApiClient(
          response: {
            'gtfs_trip_id': '115_107_180501',
            'route_type': 'bus',
            'route_short_name': '22',
            'trip_headsign': 'Bila Hora',
            'geometry': {
              'type': 'Point',
              'coordinates': [14.441252, 50.109318],
            },
            'bearing': 45,
            'delay': 10,
            'state_position': 'at_stop',
            'origin_timestamp': '2023-12-06T12:00:00+01:00',
          },
        );
        final repository = GolemioVehiclePositionRepository(apiClient);

        final position = await repository.fetchVehiclePosition(
          'service-3-1001',
        );

        expect(position.vehicleId, 'service-3-1001');
        expect(position.latitude, 50.109318);
        expect(position.longitude, 14.441252);
        expect(position.bearing, 45);
        expect(
          position.lastUpdated,
          DateTime.parse('2023-12-06T12:00:00+01:00'),
        );
      },
    );

    test('throws controlled error when vehicleId is blank', () async {
      final repository = GolemioVehiclePositionRepository(
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
        final repository = GolemioVehiclePositionRepository(
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
          repository.fetchVehiclePosition('service-3-1001'),
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

    test('throws controlled error for empty API response object', () async {
      final repository = GolemioVehiclePositionRepository(
        FakeGolemioApiClient(response: {}),
      );

      await expectLater(
        repository.fetchVehiclePosition('service-3-1001'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.invalidData,
          ),
        ),
      );
    });

    test('propagates client errors', () async {
      const expectedError = AppException(
        type: AppExceptionType.timeout,
        message: 'Timeout.',
      );
      final repository = GolemioVehiclePositionRepository(
        FakeGolemioApiClient(response: null, error: expectedError),
      );

      await expectLater(
        repository.fetchVehiclePosition('service-3-1001'),
        throwsA(same(expectedError)),
      );
    });
  });
}
