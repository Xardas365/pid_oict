import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/data/repositories/golemio_departures_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

import '../../../fakes/fake_golemio_api_client.dart';

void main() {
  group('DeparturesRepository', () {
    final stop = StopGroup.single(
      const Stop(id: 'U123Z1', name: 'Staromestska'),
    );

    test(
      'loads public departures for selected stop and skips invalid records',
      () async {
        final apiClient = mockGolemioApiClient(
          response: [
            [
              {
                'route': {'short_name': '22'},
                'trip': {'headsign': 'Nadrazi Hostivar', 'id': 'trip-22-123'},
                'departure': {
                  'timestamp_predicted': '2026-06-22T10:15:30+02:00',
                  'delay_seconds': 60,
                },
                'stop': {'id': 'U123Z1', 'platform_code': '3'},
              },
              {'line': 'A'},
            ],
          ],
        );
        final repository = GolemioDeparturesRepository(apiClient);

        final departures = await repository.fetchDeparturesForStop(stop);

        final queryParameters = verifySingleGetJson(
          apiClient,
          '/v2/public/departureboards',
          notFoundEmptyListAsSuccess: true,
        );
        expect(queryParameters, {
          'stopIds': '{"0":["U123Z1"]}',
        });
        expect(departures, hasLength(1));
        expect(departures.single.routeShortName, '22');
        expect(departures.single.headsign, 'Nadrazi Hostivar');
        expect(departures.single.delaySeconds, 60);
        expect(departures.single.platform, '3');
        expect(departures.single.stopId, 'U123Z1');
        expect(departures.single.gtfsTripId, 'trip-22-123');
      },
    );

    test(
      'aggregates duplicate grouped-stop departures and sorts by time',
      () async {
        final apiClient = mockGolemioApiClient(
          response: [
            [
              {
                'route': {'short_name': '22'},
                'trip': {'headsign': 'Nadrazi Hostivar', 'id': 'trip-22-later'},
                'departure': {
                  'timestamp_predicted': '2026-06-22T10:20:00+02:00',
                },
                'stop': {'id': 'U123Z1', 'platform_code': 'A'},
              },
              {
                'route': {'short_name': '10'},
                'trip': {'headsign': 'Sidliste Repy', 'id': 'trip-10-repy'},
                'departure': {
                  'timestamp_predicted': '2026-06-22T10:12:00+02:00',
                },
                'stop': {'id': 'U123Z1', 'platform_code': 'B'},
              },
            ],
            [
              {
                'route': {'short_name': '10'},
                'trip': {'headsign': 'Sidliste Repy', 'id': 'trip-10-repy'},
                'departure': {
                  'timestamp_predicted': '2026-06-22T10:12:00+02:00',
                },
                'stop': {'id': 'U123Z2', 'platform_code': 'C'},
              },
            ],
          ],
        );
        final repository = GolemioDeparturesRepository(apiClient);

        final departures = await repository.fetchDeparturesForStop(stop);

        expect(departures, hasLength(2));
        expect(departures.map((departure) => departure.gtfsTripId), [
          'trip-10-repy',
          'trip-22-later',
        ]);
        expect(departures.first.platform, 'B');
      },
    );

    test('encodes selected stop ids as a public departure board group', () {
      expect(
        departureBoardStopIdsValue(['U717Z5P', 'U718Z5P']),
        '{"0":["U717Z5P","U718Z5P"]}',
      );
    });

    test('sends all grouped stop ids to departure board', () async {
      final apiClient = mockGolemioApiClient(response: <Object?>[]);
      final repository = GolemioDeparturesRepository(apiClient);
      const group = StopGroup(
        id: 'U118S1',
        name: 'Flora',
        parentStationId: 'U118S1',
        zoneId: 'P',
        latitude: 50.07827,
        longitude: 14.4633,
        stops: [
          Stop(id: 'U118Z101P', name: 'Flora'),
          Stop(id: 'U118Z102P', name: 'Flora'),
          Stop(id: 'U118Z103P', name: 'Flora'),
        ],
        stopIds: ['U118Z101P', 'U118Z102P', 'U118Z103P'],
        platformCodes: ['A', 'B', 'C'],
      );

      await repository.fetchDeparturesForStop(group);

      final queryParameters = verifySingleGetJson(
        apiClient,
        '/v2/public/departureboards',
        notFoundEmptyListAsSuccess: true,
      );
      expect(queryParameters, {
        'stopIds': '{"0":["U118Z101P","U118Z102P","U118Z103P"]}',
      });
    });

    test(
      'throws controlled error when no valid departures are returned',
      () async {
        final repository = GolemioDeparturesRepository(
          mockGolemioApiClient(
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

    test('returns empty departures for empty response', () async {
      final repository = GolemioDeparturesRepository(
        mockGolemioApiClient(response: {'departures': <Object?>[]}),
      );

      expect(await repository.fetchDeparturesForStop(stop), isEmpty);
    });

    test(
      'returns empty departures for public departureboards 404 [] body',
      () async {
        final apiClient = mockGolemioApiClient(response: <Object?>[]);
        final repository = GolemioDeparturesRepository(apiClient);

        final departures = await repository.fetchDeparturesForStop(stop);

        expect(departures, isEmpty);
        verifySingleGetJson(
          apiClient,
          '/v2/public/departureboards',
          notFoundEmptyListAsSuccess: true,
        );
      },
    );

    test('propagates client errors', () async {
      const expectedError = AppException(
        type: AppExceptionType.unauthorized,
        message: 'Unauthorized.',
      );
      final repository = GolemioDeparturesRepository(
        mockGolemioApiClient(error: expectedError),
      );

      await expectLater(
        repository.fetchDeparturesForStop(stop),
        throwsA(same(expectedError)),
      );
    });
  });
}
