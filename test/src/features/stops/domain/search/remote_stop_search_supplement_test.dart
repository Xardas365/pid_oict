import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/search/remote_stop_search_supplement.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_index.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';

void main() {
  group('RemoteStopSearchSupplement', () {
    test('ignores queries below remote supplement threshold', () async {
      var calls = 0;
      final supplement = RemoteStopSearchSupplement(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const []);
        },
      );

      final result = await supplement.search(
        query: 'ce',
        index: _index(const [_cernyMost], isComplete: false),
      );

      expect(result, isNull);
      expect(calls, 0);
    });

    test(
      'does not call remote supplement when local index is complete',
      () async {
        var calls = 0;
        final supplement = RemoteStopSearchSupplement(
          searchLimit: 100,
          minApiSearchLength: 3,
          searchStops: ({required limit, required query}) async {
            calls++;
            return _page(const [_floraPlatformA]);
          },
        );

        final result = await supplement.search(
          query: 'flo',
          index: _index(const [_floraPlatformA], isComplete: true),
        );

        expect(result, isNull);
        expect(calls, 0);
      },
    );

    test('deduplicates and sorts remote supplement results', () async {
      final queries = <String>[];
      final supplement = RemoteStopSearchSupplement(
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

      final result = await supplement.search(
        query: ' flo ',
        index: _index(const [_andel, _floraPlatformA], isComplete: false),
      );

      expect(queries, ['flo:100']);
      expect(result, isNotNull);
      expect(result!.normalizedQuery, 'flo');
      expect(result.stops.map((stop) => '${stop.name}:${stop.id}'), [
        'Andel:U123Z1',
        'Flora updated:U118Z102P',
      ]);
    });

    test(
      'returns an empty remote supplement without clearing local matches',
      () async {
        final supplement = RemoteStopSearchSupplement(
          searchLimit: 100,
          minApiSearchLength: 3,
          searchStops: ({required limit, required query}) async {
            return _page(const []);
          },
        );

        final result = await supplement.search(
          query: 'cer',
          index: _index(const [_cernyMost], isComplete: false),
        );

        expect(result, isNotNull);
        expect(result!.normalizedQuery, 'cer');
        expect(result.stops, isEmpty);
      },
    );

    test('does not call API again for the same normalized query', () async {
      var calls = 0;
      final supplement = RemoteStopSearchSupplement(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const [_floraPlatformA]);
        },
      );

      final firstResult = await supplement.search(
        query: ' flo ',
        index: _index(const [], isComplete: false),
      );
      final secondResult = await supplement.search(
        query: 'flo',
        index: _index(const [], isComplete: false),
      );

      expect(firstResult, isNotNull);
      expect(secondResult, isNull);
      expect(calls, 1);
    });

    test('reset allows the same query to be searched again', () async {
      var calls = 0;
      final supplement = RemoteStopSearchSupplement(
        searchLimit: 100,
        minApiSearchLength: 3,
        searchStops: ({required limit, required query}) async {
          calls++;
          return _page(const [_floraPlatformA]);
        },
      );

      await supplement.search(
        query: 'flo',
        index: _index(const [], isComplete: false),
      );
      supplement.resetLastRequestedSearch();
      final result = await supplement.search(
        query: 'flo',
        index: _index(const [], isComplete: false),
      );

      expect(result, isNotNull);
      expect(calls, 2);
    });
  });
}

StopSearchIndex _index(List<Stop> stops, {required bool isComplete}) {
  return StopSearchIndex.fromGroups(
    groupStops(stops),
    isComplete: isComplete,
  );
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
