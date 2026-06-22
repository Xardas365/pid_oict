import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/data/stops_repository.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('StopsRepository', () {
    test('loads stops and skips invalid records', () async {
      final apiClient = FakeGolemioApiClient(
        response: {
          'features': [
            {
              'geometry': {
                'type': 'Point',
                'coordinates': [14.42076, 50.08804],
              },
              'properties': {
                'stop_id': 'U123Z1',
                'stop_name': 'Staromestska',
                'platform_code': 'A',
              },
            },
            {
              'properties': {'stop_id': 'missing-name'},
            },
          ],
        },
      );
      final repository = StopsRepository(apiClient);

      final stops = await repository.fetchStops();

      expect(apiClient.calls, hasLength(1));
      expect(apiClient.calls.single.path, '/v2/gtfs/stops');
      expect(apiClient.calls.single.queryParameters, isEmpty);
      expect(stops, hasLength(1));
      expect(stops.single.id, 'U123Z1');
      expect(stops.single.name, 'Staromestska');
      expect(stops.single.latitude, 50.08804);
      expect(stops.single.longitude, 14.42076);
    });

    test('throws controlled error when no valid stops are returned', () async {
      final repository = StopsRepository(
        FakeGolemioApiClient(
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

    test('propagates client errors', () async {
      const expectedError = AppException(
        type: AppExceptionType.missingToken,
        message: 'Missing token.',
      );
      final repository = StopsRepository(
        FakeGolemioApiClient(response: null, error: expectedError),
      );

      await expectLater(repository.fetchStops(), throwsA(same(expectedError)));
    });
  });
}
