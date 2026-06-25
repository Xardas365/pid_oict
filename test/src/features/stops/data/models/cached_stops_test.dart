import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  group('CachedStops', () {
    test('serializes cached public stops', () {
      final cachedStops = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 10),
        stops: const [_publicStop],
        hasMore: true,
        nextOffset: 500,
      );

      final json = cachedStops.toJson();

      expect(json['schemaVersion'], stopsCacheSchemaVersion);
      expect(json['cachedAt'], '2026-06-23T10:00:00.000Z');
      expect(json['hasMore'], isTrue);
      expect(json['nextOffset'], 500);
      expect(json['stops'], [
        {
          'id': 'U118Z101P',
          'name': 'Flora',
          'platformCode': 'A',
          'zoneId': 'P',
          'locationType': 0,
          'parentStationId': 'U118S1',
          'wheelchairBoarding': 2,
          'levelId': 'U118L2',
          'latitude': 50.07827,
          'longitude': 14.4633,
        },
      ]);
    });

    test('deserializes cached public stops', () {
      final cachedStops = CachedStops.fromJson({
        'schemaVersion': stopsCacheSchemaVersion,
        'cachedAt': '2026-06-23T10:00:00.000Z',
        'stops': [
          {
            'id': 'U118Z101P',
            'name': 'Flora',
            'platformCode': 'A',
            'zoneId': 'P',
            'locationType': 0,
            'parentStationId': 'U118S1',
            'wheelchairBoarding': 2,
            'levelId': 'U118L2',
            'latitude': 50.07827,
            'longitude': 14.4633,
          },
        ],
      });

      expect(cachedStops, isNotNull);
      expect(cachedStops!.schemaVersion, stopsCacheSchemaVersion);
      expect(cachedStops.cachedAt, DateTime.utc(2026, 6, 23, 10));
      expect(cachedStops.hasMore, isFalse);
      expect(cachedStops.nextOffset, 1);
      expect(cachedStops.stops, hasLength(1));

      final stop = cachedStops.stops.single;
      expect(stop.id, 'U118Z101P');
      expect(stop.name, 'Flora');
      expect(stop.platformCode, 'A');
      expect(stop.zoneId, 'P');
      expect(stop.locationType, 0);
      expect(stop.parentStationId, 'U118S1');
      expect(stop.wheelchairBoarding, 2);
      expect(stop.levelId, 'U118L2');
      expect(stop.latitude, 50.07827);
      expect(stop.longitude, 14.4633);
    });

    test('deserializes pagination metadata', () {
      final cachedStops = CachedStops.fromJson({
        'schemaVersion': stopsCacheSchemaVersion,
        'cachedAt': '2026-06-23T10:00:00.000Z',
        'hasMore': true,
        'nextOffset': 500,
        'stops': [
          {'id': 'U118Z101P', 'name': 'Flora'},
        ],
      });

      expect(cachedStops, isNotNull);
      expect(cachedStops!.hasMore, isTrue);
      expect(cachedStops.nextOffset, 500);
    });

    test('round trips search alias metadata without changing schema', () {
      final cachedStops = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 10),
        stops: const [
          Stop(
            id: 'U202Z101P',
            name: 'Hlavní nádraží',
            parentStationId: 'U202S1',
            searchAliases: ['Praha hlavní nádraží'],
          ),
        ],
      );

      final json = cachedStops.toJson();
      final restored = CachedStops.fromJson(json);

      expect(json['schemaVersion'], stopsCacheSchemaVersion);
      expect(
        (json['stops']! as List).single,
        containsPair('searchAliases', ['Praha hlavní nádraží']),
      );
      expect(restored, isNotNull);
      expect(restored!.stops.single.searchAliases, ['Praha hlavní nádraží']);
    });

    test('ignores unsupported schema versions safely', () {
      final cachedStops = CachedStops.fromJson({
        'schemaVersion': stopsCacheSchemaVersion + 1,
        'cachedAt': '2026-06-23T10:00:00.000Z',
        'stops': [
          {'id': 'U118Z101P', 'name': 'Flora'},
        ],
      });

      expect(cachedStops, isNull);
    });

    test('returns null for invalid cache shape', () {
      expect(
        CachedStops.fromJson({
          'schemaVersion': stopsCacheSchemaVersion,
          'cachedAt': '2026-06-23T10:00:00.000Z',
          'stops': [
            {'id': 'missing-name'},
          ],
        }),
        isNull,
      );
      expect(
        CachedStops.fromJson({
          'schemaVersion': stopsCacheSchemaVersion,
          'cachedAt': 'not-a-date',
          'stops': const <Object?>[],
        }),
        isNull,
      );
    });

    test('evaluates cache freshness with the default TTL', () {
      final cachedStops = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 10),
        stops: const [_publicStop],
      );

      expect(cachedStops.isFresh(DateTime.utc(2026, 6, 24, 9, 59)), isTrue);
      expect(cachedStops.isFresh(DateTime.utc(2026, 6, 24, 10, 1)), isFalse);
      expect(isStopsCacheFresh(null, DateTime.utc(2026, 6, 23, 10)), isFalse);
    });
  });
}

const _publicStop = Stop(
  id: 'U118Z101P',
  name: 'Flora',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  wheelchairBoarding: 2,
  levelId: 'U118L2',
  latitude: 50.07827,
  longitude: 14.4633,
);
