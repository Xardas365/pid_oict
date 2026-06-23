import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/datasources/app_stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  group('resolveAppStopsCacheFile', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_app_stops_cache_test_',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('resolves an app-specific stops cache path', () async {
      final file = await resolveAppStopsCacheFile(
        directoryResolver: () async => tempDirectory,
      );

      expect(file.path, contains(tempDirectory.path));
      expect(file.path, contains(stopsCacheDirectoryName));
      expect(file.path, endsWith(stopsCacheFileName));
    });
  });

  group('AppStopsCacheDataSource', () {
    late Directory tempDirectory;
    late File cacheFile;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_app_stops_cache_data_source_test_',
      );
      cacheFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}$stopsCacheFileName',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('reads, writes, and clears through the resolved file', () async {
      final dataSource = AppStopsCacheDataSource(
        fileResolver: () async => cacheFile,
      );
      final cache = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 12),
        stops: const [_publicStop],
      );

      expect(await dataSource.read(), isNull);

      await dataSource.write(cache);
      final restoredCache = await dataSource.read();

      expect(restoredCache, isNotNull);
      expect(restoredCache!.stops.single.id, _publicStop.id);

      await dataSource.clear();
      expect(await dataSource.read(), isNull);
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
  latitude: 50.07827,
  longitude: 14.4633,
);
