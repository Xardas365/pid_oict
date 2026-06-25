import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';
import 'package:pid_oict/src/features/vehicle_map/data/repositories/golemio_vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('VehiclePositionRepository', () {
    test('loads the first valid vehicle position', () async {
      final apiClient = mockGolemioApiClient(
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
      final repository = _repository(apiClient);

      final position = await repository.fetchVehiclePosition(
        VehicleId('service-3-1001'),
      );

      final queryParameters = verifySingleGetJson(
        apiClient,
        '/v2/public/vehiclepositions/service-3-1001',
      );
      expect(
        queryParameters.toSingleValueMap(),
        {'scopes': 'info'},
      );
      expect(position.vehicleId, 'tram-22-123');
      expect(position.latitude, 50.0755);
      expect(position.longitude, 14.4378);
      expect(position.bearing, 87.5);
    });

    test('encodes vehicleId as one path segment', () async {
      final apiClient = mockGolemioApiClient(
        response: {
          'geometry': {
            'type': 'Point',
            'coordinates': [14.4378, 50.0755],
          },
          'properties': {'vehicle_id': 'vehicle/with slash'},
        },
      );
      final repository = _repository(apiClient);

      await repository.fetchVehiclePosition(VehicleId('service/with slash'));

      expect(
        verifySingleGetJson(
          apiClient,
          '/v2/public/vehiclepositions/service%2Fwith%20slash',
        ).toSingleValueMap(),
        {'scopes': 'info'},
      );
    });

    test(
      'uses request vehicleId when response body omits vehicle id',
      () async {
        final apiClient = mockGolemioApiClient(
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
        final repository = _repository(apiClient);

        final position = await repository.fetchVehiclePosition(
          VehicleId('service-3-1001'),
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

    test(
      'throws controlled error when no valid position is returned',
      () async {
        final repository = _repository(
          mockGolemioApiClient(
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
          repository.fetchVehiclePosition(VehicleId('service-3-1001')),
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
      final repository = _repository(mockGolemioApiClient(response: {}));

      await expectLater(
        repository.fetchVehiclePosition(VehicleId('service-3-1001')),
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
      final repository = _repository(
        mockGolemioApiClient(error: expectedError),
      );

      await expectLater(
        repository.fetchVehiclePosition(VehicleId('service-3-1001')),
        throwsA(same(expectedError)),
      );
    });
  });
}

GolemioVehiclePositionRepository _repository(MockGolemioApiClient apiClient) {
  return GolemioVehiclePositionRepository(
    VehiclePositionsRemoteDataSource(apiClient),
  );
}
