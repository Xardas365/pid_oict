import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/datasources/file_stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

import '../../../../../helpers/in_memory_stops_cache_data_source.dart';

void main() {
  group('FileStopsCacheDataSource', () {
    late Directory tempDirectory;
    late File cacheFile;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'pid_oict_stops_cache_test_',
      );
      cacheFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}stops.json',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('returns null when the cache file does not exist', () async {
      final dataSource = FileStopsCacheDataSource(cacheFile);

      expect(await dataSource.read(), isNull);
    });

    test('writes and reads cached stops', () async {
      final dataSource = FileStopsCacheDataSource(cacheFile);
      final cache = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 10),
        stops: const [_publicStop],
      );

      await dataSource.write(cache);
      final restoredCache = await dataSource.read();

      expect(restoredCache, isNotNull);
      expect(restoredCache!.cachedAt, DateTime.utc(2026, 6, 23, 10));
      expect(restoredCache.stops.single.id, 'U118Z101P');
      expect(restoredCache.stops.single.name, 'Flora');
    });

    test('clear removes the cached file', () async {
      final dataSource = FileStopsCacheDataSource(cacheFile);
      await dataSource.write(
        CachedStops(
          cachedAt: DateTime.utc(2026, 6, 23, 10),
          stops: const [_publicStop],
        ),
      );

      await dataSource.clear();

      expect(await cacheFile.exists(), isFalse);
      expect(await dataSource.read(), isNull);
    });

    test('corrupted cache returns a safe miss', () async {
      final dataSource = FileStopsCacheDataSource(cacheFile);
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsString('{not-json');

      expect(await dataSource.read(), isNull);
    });

    test('unsupported schema version returns a safe miss', () async {
      final dataSource = FileStopsCacheDataSource(cacheFile);
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsString('''
{
  "schemaVersion": 999,
  "cachedAt": "2026-06-23T10:00:00.000Z",
  "stops": [
    {"id": "U118Z101P", "name": "Flora"}
  ]
}
''');

      expect(await dataSource.read(), isNull);
    });
  });

  group('InMemoryStopsCacheDataSource', () {
    test('supports read, write, and clear', () async {
      final dataSource = InMemoryStopsCacheDataSource();
      final cache = CachedStops(
        cachedAt: DateTime.utc(2026, 6, 23, 10),
        stops: const [_publicStop],
      );

      expect(await dataSource.read(), isNull);

      await dataSource.write(cache);
      expect(await dataSource.read(), same(cache));

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
