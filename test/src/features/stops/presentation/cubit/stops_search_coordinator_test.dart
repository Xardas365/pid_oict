import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_search_coordinator.dart';

void main() {
  group('StopsSearchCoordinator', () {
    test('ignores queries below API search threshold', () async {
      var calls = 0;
      final coordinator = StopsSearchCoordinator(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const []);
        },
      );

      final result = await coordinator.search(
        query: 'ce',
        loadedStops: const [_cernyMost],
      );

      expect(result, isNull);
      expect(calls, 0);
    });

    test('deduplicates and sorts API search results', () async {
      final queries = <String>[];
      final coordinator = StopsSearchCoordinator(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          queries.add('$query:$limit');
          return _page(
            const [
              _floraPlatformB,
              _andel,
              Stop(
                id: 'U118Z102P',
                name: 'Flora updated',
                platformCode: 'B',
                zoneId: 'P',
                locationType: 0,
                parentStationId: 'U118S1',
              ),
            ],
          );
        },
      );

      final result = await coordinator.search(
        query: ' flo ',
        loadedStops: const [_andel, _floraPlatformA],
      );

      expect(queries, ['flo:100']);
      expect(result, isNotNull);
      expect(result!.useLocalFallback, isFalse);
      expect(result.normalizedQuery, 'flo');
      expect(result.stops.map((stop) => '${stop.name}:${stop.id}'), [
        'Andel:U123Z1',
        'Flora updated:U118Z102P',
      ]);
    });

    test(
      'returns local fallback when API result is empty but local matches',
      () async {
        final coordinator = StopsSearchCoordinator(
          searchLimit: 100,
          minApiSearchLength: 3,
          searchStops: ({required limit, required query}) async {
            return _page(const []);
          },
        );

        final result = await coordinator.search(
          query: 'cer',
          loadedStops: const [_cernyMost],
        );

        expect(result, isNotNull);
        expect(result!.useLocalFallback, isTrue);
        expect(result.normalizedQuery, 'cer');
        expect(result.stops, isEmpty);
      },
    );

    test('does not call API again for the same normalized query', () async {
      var calls = 0;
      final coordinator = StopsSearchCoordinator(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const [_floraPlatformA]);
        },
      );

      final firstResult = await coordinator.search(
        query: ' flo ',
        loadedStops: const [],
      );
      final secondResult = await coordinator.search(
        query: 'flo',
        loadedStops: const [],
      );

      expect(firstResult, isNotNull);
      expect(secondResult, isNull);
      expect(calls, 1);
    });

    test('reset allows the same query to be searched again', () async {
      var calls = 0;
      final coordinator = StopsSearchCoordinator(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const [_floraPlatformA]);
        },
      );

      await coordinator.search(query: 'flo', loadedStops: const []);
      coordinator.resetLastRequestedSearch();
      final result = await coordinator.search(
        query: 'flo',
        loadedStops: const [],
      );

      expect(result, isNotNull);
      expect(calls, 2);
    });
  });
}

StopsPage _page(List<Stop> stops) {
  return StopsPage(
    stops: stops,
    limit: 100,
    offset: 0,
    rawReturnedCount: stops.length,
    hasMore: false,
  );
}

const _andel = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U123S1',
  latitude: 50.07128,
  longitude: 14.40312,
);

const _floraPlatformA = Stop(
  id: 'U118Z101P',
  name: 'Flora',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07827,
  longitude: 14.4633,
);

const _floraPlatformB = Stop(
  id: 'U118Z102P',
  name: 'Flora',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07831,
  longitude: 14.4631,
);

const _cernyMost = Stop(
  id: 'U122Z101P',
  name: 'Černý Most',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U122S1',
  latitude: 50.10878,
  longitude: 14.57792,
);
