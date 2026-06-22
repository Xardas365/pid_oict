import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/data/departures_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('DeparturesRepository', () {
    const stop = Stop(id: 'U123Z1', name: 'Staromestska');

    test(
      'loads departures for selected stop and skips invalid records',
      () async {
        final apiClient = FakeGolemioApiClient(
          response: {
            'departures': [
              {
                'route': {'short_name': '22'},
                'trip': {'headsign': 'Nadrazi Hostivar'},
                'departure': {
                  'predicted': '2026-06-22T10:15:30+02:00',
                  'delay_seconds': 60,
                },
                'platform': '3',
                'vehicle': {'id': 'vehicle-123'},
              },
              {'line': 'A'},
            ],
          },
        );
        final repository = DeparturesRepository(apiClient);

        final departures = await repository.fetchDeparturesForStop(stop);

        expect(apiClient.calls, hasLength(1));
        expect(apiClient.calls.single.path, '/v2/public/departureboards');
        expect(apiClient.calls.single.queryParameters, {
          departureBoardsStopFilterParameter: 'U123Z1',
        });
        expect(departures, hasLength(1));
        expect(departures.single.routeShortName, '22');
        expect(departures.single.headsign, 'Nadrazi Hostivar');
        expect(departures.single.delaySeconds, 60);
        expect(departures.single.platform, '3');
        expect(departures.single.vehicleId, 'vehicle-123');
      },
    );

    test(
      'throws controlled error when no valid departures are returned',
      () async {
        final repository = DeparturesRepository(
          FakeGolemioApiClient(
            response: {
              'departures': [
                {'line': 'A'},
              ],
            },
          ),
        );

        await expectLater(
          repository.fetchDeparturesForStop(stop),
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
