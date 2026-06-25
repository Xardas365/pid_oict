import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/data/datasources/stops_remote_data_source.dart';
import 'package:pid_oict/src/features/stops/data/repositories/golemio_stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('StopsRepository', () {
    test(
      'loads public stops, filters technical records, and sorts by name',
      () async {
        final apiClient = mockGolemioApiClient(
          response: {
            'features': [
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.4633, 50.07827],
                },
                'properties': {
                  'stop_id': 'U2Z1',
                  'stop_name': 'Flora',
                  'platform_code': 'A',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.40312, 50.07128],
                },
                'properties': {
                  'stop_id': 'U1Z1',
                  'stop_name': 'Andel',
                  'platform_code': 'B',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.5, 50.1],
                },
                'properties': {
                  'stop_id': 'T53297',
                  'stop_name': 'vl. v km 12,4',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.51, 50.11],
                },
                'properties': {
                  'stop_id': 'U3Z1',
                  'stop_name': 'hr.VUSC Praha',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.52, 50.12],
                },
                'properties': {
                  'stop_id': 'U4Z1',
                  'stop_name': 'Kolín výh.č.1',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.53, 50.13],
                },
                'properties': {
                  'stop_id': 'U5Z1',
                  'stop_name': 'Station container',
                  'zone_id': 'P',
                  'location_type': 1,
                },
              },
              {
                'geometry': {
                  'type': 'Point',
                  'coordinates': [14.54, 50.14],
                },
                'properties': {
                  'stop_id': 'U6Z1',
                  'stop_name': 'Missing zone',
                  'location_type': 0,
                },
              },
              {
                'properties': {
                  'stop_id': 'U7Z1',
                  'stop_name': 'Missing coordinates',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
              {
                'properties': {
                  'stop_id': 'missing-name',
                  'zone_id': 'P',
                  'location_type': 0,
                },
              },
            ],
          },
        );
        final repository = _repository(apiClient);

        final stops = await repository.fetchStops();

        expect(
          verifySingleGetJson(apiClient, '/v2/gtfs/stops').encoded,
          'limit=1000&offset=0',
        );
        expect(stops.map((stop) => stop.name), ['Andel', 'Flora']);
        expect(stops.first.id, 'U1Z1');
        expect(stops.first.latitude, 50.07128);
        expect(stops.first.longitude, 14.40312);
      },
    );

    test('loads a page with limit and offset and reports hasMore', () async {
      final apiClient = mockGolemioApiClient(
        response: {
          'features': [
            _stopFeature(
              id: 'U1Z1',
              name: 'Andel',
              longitude: 14.40312,
              latitude: 50.07128,
            ),
            _stopFeature(
              id: 'T53297',
              name: 'vl. v km 12,4',
              longitude: 14.5,
              latitude: 50.1,
            ),
          ],
        },
      );
      final repository = _repository(apiClient);

      final page = await repository.fetchStopsPage(
        const GtfsStopsQuery(limit: 2, offset: 10),
      );

      expect(
        verifySingleGetJson(apiClient, '/v2/gtfs/stops').encoded,
        'limit=2&offset=10',
      );
      expect(page.limit, 2);
      expect(page.offset, 10);
      expect(page.rawReturnedCount, 2);
      expect(page.hasMore, isTrue);
      expect(page.stops.map((stop) => stop.name), ['Andel']);
    });

    test('loads an API search page with names array parameter', () async {
      final apiClient = mockGolemioApiClient(
        response: {
          'features': [
            _stopFeature(
              id: 'U2Z1',
              name: 'Flora',
              longitude: 14.4633,
              latitude: 50.07827,
            ),
          ],
        },
      );
      final repository = _repository(apiClient);

      final page = await repository.fetchStopsPage(
        const GtfsStopsQuery(limit: 100, offset: 0, names: ['Flora']),
      );

      expect(
        verifySingleGetJson(
          apiClient,
          '/v2/gtfs/stops',
        ).encoded,
        'names[]=Flora&limit=100&offset=0',
      );
      expect(page.hasMore, isFalse);
      expect(page.stops.single.name, 'Flora');
    });

    test('throws controlled error when no valid stops are returned', () async {
      final repository = _repository(
        mockGolemioApiClient(
          response: {
            'features': [
              {
                'properties': {'stop_id': 'missing-name'},
              },
            ],
          },
        ),
      );

      await expectLater(
        repository.fetchStops(),
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
      'throws controlled error when only technical stops are returned',
      () async {
        final repository = _repository(
          mockGolemioApiClient(
            response: {
              'features': [
                {
                  'geometry': {
                    'type': 'Point',
                    'coordinates': [14.5, 50.1],
                  },
                  'properties': {
                    'stop_id': 'T53297',
                    'stop_name': 'vl. v km 12,4',
                    'zone_id': 'P',
                    'location_type': 0,
                  },
                },
              ],
            },
          ),
        );

        await expectLater(
          repository.fetchStops(),
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
        repository.fetchStops(),
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
        type: AppExceptionType.missingToken,
        message: 'Missing token.',
      );
      final repository = _repository(
        mockGolemioApiClient(error: expectedError),
      );

      await expectLater(repository.fetchStops(), throwsA(same(expectedError)));
    });
  });
}

GolemioStopsRepository _repository(MockGolemioApiClient apiClient) {
  return GolemioStopsRepository(StopsRemoteDataSource(apiClient));
}

Map<String, Object?> _stopFeature({
  required String id,
  required String name,
  required double longitude,
  required double latitude,
  String zoneId = 'P',
  int locationType = 0,
}) {
  return {
    'geometry': {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    },
    'properties': {
      'stop_id': id,
      'stop_name': name,
      'zone_id': zoneId,
      'location_type': locationType,
    },
  };
}
