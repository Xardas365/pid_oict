import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/datasources/file_saved_stops_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';

import '../../../../../helpers/in_memory_saved_stops_data_source.dart';

void main() {
  group('FileSavedStopsDataSource', () {
    late Directory tempDirectory;
    late File favoritesFile;
    late File recentFile;
    late FileSavedStopsDataSource dataSource;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_saved_stops_test_',
      );
      favoritesFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}favorite_stops.json',
      );
      recentFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}recent_stops.json',
      );
      dataSource = FileSavedStopsDataSource(
        favoritesFile: favoritesFile,
        recentFile: recentFile,
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('returns empty defaults when files do not exist', () async {
      final favorites = await dataSource.readFavorites();
      final recent = await dataSource.readRecent();

      expect(favorites.favoriteGroupIds, isEmpty);
      expect(recent.recentGroupIds, isEmpty);
    });

    test('writes and reads favorites and recent stops', () async {
      await dataSource.writeFavorites(
        FavoriteStops(
          updatedAt: _now,
          favoriteGroupIds: const ['U118S1', 'name:andel'],
        ),
      );
      await dataSource.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['name:andel']),
      );

      final favorites = await dataSource.readFavorites();
      final recent = await dataSource.readRecent();

      expect(favorites.favoriteGroupIds, ['U118S1', 'name:andel']);
      expect(recent.recentGroupIds, ['name:andel']);
    });

    test('clear favorites does not affect recent stops', () async {
      await dataSource.writeFavorites(
        FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U118S1']),
      );
      await dataSource.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['U118S1']),
      );

      await dataSource.clearFavorites();

      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, ['U118S1']);
    });

    test('clear recent does not affect favorites', () async {
      await dataSource.writeFavorites(
        FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U118S1']),
      );
      await dataSource.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['U118S1']),
      );

      await dataSource.clearRecent();

      expect((await dataSource.readFavorites()).favoriteGroupIds, ['U118S1']);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);
    });

    test('corrupted files return empty defaults', () async {
      await favoritesFile.writeAsString('{not-json');
      await recentFile.writeAsString('{not-json');

      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);
    });

    test('unsupported schema versions return empty defaults', () async {
      await favoritesFile.writeAsString('''
{
  "schemaVersion": 999,
  "updatedAt": "2026-06-23T12:00:00.000Z",
  "favoriteGroupIds": ["U118S1"]
}
''');
      await recentFile.writeAsString('''
{
  "schemaVersion": 999,
  "updatedAt": "2026-06-23T12:00:00.000Z",
  "recentGroupIds": ["U118S1"]
}
''');

      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);
    });
  });

  group('InMemorySavedStopsDataSource', () {
    test('supports read, write, and clear', () async {
      final dataSource = InMemorySavedStopsDataSource();
      final favorites = FavoriteStops(
        updatedAt: _now,
        favoriteGroupIds: const ['U118S1'],
      );
      final recent = RecentStops(
        updatedAt: _now,
        recentGroupIds: const ['U118S1'],
      );

      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);

      await dataSource.writeFavorites(favorites);
      await dataSource.writeRecent(recent);
      expect(await dataSource.readFavorites(), same(favorites));
      expect(await dataSource.readRecent(), same(recent));

      await dataSource.clearFavorites();
      await dataSource.clearRecent();
      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);
    });
  });
}

final _now = DateTime.utc(2026, 6, 23, 12);
