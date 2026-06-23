import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';

void main() {
  group('FavoriteStops', () {
    test('serializes favorite group ids', () {
      final favorites = FavoriteStops(
        updatedAt: DateTime.utc(2026, 6, 23, 12),
        favoriteGroupIds: const ['U118S1', 'name:andel'],
      );

      expect(favorites.toJson(), {
        'schemaVersion': savedStopsSchemaVersion,
        'updatedAt': '2026-06-23T12:00:00.000Z',
        'favoriteGroupIds': ['U118S1', 'name:andel'],
      });
    });

    test('deserializes and normalizes favorite group ids', () {
      final favorites = FavoriteStops.fromJson({
        'schemaVersion': savedStopsSchemaVersion,
        'updatedAt': '2026-06-23T12:00:00.000Z',
        'favoriteGroupIds': [' U118S1 ', '', 'U118S1', 'name:andel'],
      });

      expect(favorites, isNotNull);
      expect(favorites!.updatedAt, DateTime.utc(2026, 6, 23, 12));
      expect(favorites.favoriteGroupIds, ['U118S1', 'name:andel']);
    });

    test('add preserves chosen order and ignores duplicates', () {
      final favorites = FavoriteStops.empty()
          .add('U118S1', updatedAt: _now)
          .add('name:andel', updatedAt: _now)
          .add('U118S1', updatedAt: _later);

      expect(favorites.favoriteGroupIds, ['U118S1', 'name:andel']);
      expect(favorites.updatedAt, _now);
    });

    test('remove affects only the requested favorite id', () {
      final favorites = FavoriteStops(
        updatedAt: _now,
        favoriteGroupIds: const ['U118S1', 'name:andel'],
      ).remove('U118S1', updatedAt: _later);

      expect(favorites.favoriteGroupIds, ['name:andel']);
      expect(favorites.updatedAt, _later);
    });

    test('returns null for unsupported or invalid JSON', () {
      expect(
        FavoriteStops.fromJson({
          'schemaVersion': savedStopsSchemaVersion + 1,
          'updatedAt': '2026-06-23T12:00:00.000Z',
          'favoriteGroupIds': ['U118S1'],
        }),
        isNull,
      );
      expect(
        FavoriteStops.fromJson({
          'schemaVersion': savedStopsSchemaVersion,
          'updatedAt': 'not-a-date',
          'favoriteGroupIds': ['U118S1'],
        }),
        isNull,
      );
      expect(
        FavoriteStops.fromJson({
          'schemaVersion': savedStopsSchemaVersion,
          'updatedAt': '2026-06-23T12:00:00.000Z',
          'favoriteGroupIds': 'U118S1',
        }),
        isNull,
      );
    });
  });

  group('RecentStops', () {
    test('serializes recent group ids', () {
      final recent = RecentStops(
        updatedAt: DateTime.utc(2026, 6, 23, 12),
        recentGroupIds: const ['U118S1', 'name:andel'],
      );

      expect(recent.toJson(), {
        'schemaVersion': savedStopsSchemaVersion,
        'updatedAt': '2026-06-23T12:00:00.000Z',
        'recentGroupIds': ['U118S1', 'name:andel'],
      });
    });

    test('deserializes, deduplicates, and caps recent group ids', () {
      final recent = RecentStops.fromJson({
        'schemaVersion': savedStopsSchemaVersion,
        'updatedAt': '2026-06-23T12:00:00.000Z',
        'recentGroupIds': [
          ' U1 ',
          'U2',
          'U1',
          'U3',
          'U4',
          'U5',
          'U6',
          'U7',
          'U8',
          'U9',
          'U10',
          'U11',
        ],
      });

      expect(recent, isNotNull);
      expect(recent!.recentGroupIds, [
        'U1',
        'U2',
        'U3',
        'U4',
        'U5',
        'U6',
        'U7',
        'U8',
        'U9',
        'U10',
      ]);
    });

    test('add orders newest first and moves existing ids to top', () {
      final recent = RecentStops.empty()
          .add('U1', updatedAt: _now)
          .add('U2', updatedAt: _later)
          .add('U1', updatedAt: _latest);

      expect(recent.recentGroupIds, ['U1', 'U2']);
      expect(recent.updatedAt, _latest);
    });

    test('add caps recent ids to the configured max count', () {
      var recent = RecentStops.empty();

      for (var index = 0; index < maxRecentStopsCount + 2; index++) {
        recent = recent.add('U$index', updatedAt: _now);
      }

      expect(recent.recentGroupIds, hasLength(maxRecentStopsCount));
      expect(recent.recentGroupIds.first, 'U11');
      expect(recent.recentGroupIds.last, 'U2');
    });

    test('returns null for unsupported or invalid JSON', () {
      expect(
        RecentStops.fromJson({
          'schemaVersion': savedStopsSchemaVersion + 1,
          'updatedAt': '2026-06-23T12:00:00.000Z',
          'recentGroupIds': ['U118S1'],
        }),
        isNull,
      );
      expect(
        RecentStops.fromJson({
          'schemaVersion': savedStopsSchemaVersion,
          'updatedAt': 'not-a-date',
          'recentGroupIds': ['U118S1'],
        }),
        isNull,
      );
    });
  });
}

final _now = DateTime.utc(2026, 6, 23, 12);
final _later = DateTime.utc(2026, 6, 23, 13);
final _latest = DateTime.utc(2026, 6, 23, 14);
