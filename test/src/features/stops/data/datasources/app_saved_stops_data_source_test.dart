import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/datasources/app_saved_stops_data_source.dart';
import 'package:pid_oict/src/features/stops/data/datasources/app_stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';

void main() {
  group('resolveAppSavedStopsFiles', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_app_saved_stops_test_',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('resolves app-specific favorites and recent paths', () async {
      final files = await resolveAppSavedStopsFiles(
        directoryResolver: () async => tempDirectory,
      );

      expect(files.favoritesFile.path, contains(tempDirectory.path));
      expect(files.favoritesFile.path, contains(stopsCacheDirectoryName));
      expect(files.favoritesFile.path, endsWith(favoriteStopsFileName));
      expect(files.recentFile.path, contains(tempDirectory.path));
      expect(files.recentFile.path, contains(stopsCacheDirectoryName));
      expect(files.recentFile.path, endsWith(recentStopsFileName));
    });
  });

  group('AppSavedStopsDataSource', () {
    late Directory tempDirectory;
    late SavedStopsFiles files;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_app_saved_stops_data_source_test_',
      );
      final separator = Platform.pathSeparator;
      files = SavedStopsFiles(
        favoritesFile: File(
          '${tempDirectory.path}$separator$favoriteStopsFileName',
        ),
        recentFile: File(
          '${tempDirectory.path}${Platform.pathSeparator}$recentStopsFileName',
        ),
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('reads, writes, and clears through resolved files', () async {
      final dataSource = AppSavedStopsDataSource(
        filesResolver: () async => files,
      );
      final favorites = FavoriteStops(
        updatedAt: _now,
        favoriteGroupIds: const ['U118S1'],
      );
      final recent = RecentStops(
        updatedAt: _now,
        recentGroupIds: const ['U118S1'],
      );

      await dataSource.writeFavorites(favorites);
      await dataSource.writeRecent(recent);

      expect((await dataSource.readFavorites()).favoriteGroupIds, ['U118S1']);
      expect((await dataSource.readRecent()).recentGroupIds, ['U118S1']);

      await dataSource.clearFavorites();
      await dataSource.clearRecent();

      expect((await dataSource.readFavorites()).favoriteGroupIds, isEmpty);
      expect((await dataSource.readRecent()).recentGroupIds, isEmpty);
    });
  });
}

final _now = DateTime.utc(2026, 6, 23, 12);
