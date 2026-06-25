import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/saved_stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_cache_repository.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/saved_stop_groups.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stops_cache_snapshot.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_cached_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_complete_stop_index_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_saved_stop_groups_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/load_stop_groups_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/record_recent_stop_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/refresh_stop_groups_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/remote_supplement_stop_search_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/save_stops_cache_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';

void main() {
  group('stops orchestration use cases', () {
    test(
      'load, refresh, and remote supplement use cases build expected queries',
      () async {
        final repository = _RecordingStopsRepository();
        final getStops = GetStopsUseCase(repository);

        await LoadStopGroupsUseCase(getStops)(limit: 500, offset: 1000);
        await RefreshStopGroupsUseCase(getStops)(limit: 500);
        await RemoteSupplementStopSearchUseCase(getStops)(
          query: 'Flo',
          limit: 100,
        );

        expect(repository.queries, hasLength(3));
        expect(repository.queries[0].limit, 500);
        expect(repository.queries[0].offset, 1000);
        expect(repository.queries[1].limit, 500);
        expect(repository.queries[1].offset, 0);
        expect(repository.queries[2].limit, 100);
        expect(repository.queries[2].offset, 0);
        expect(repository.queries[2].names, ['Flo']);
      },
    );

    test(
      'complete index loader fetches pages until hasMore is false',
      () async {
        const flora = Stop(id: 'U118Z101P', name: 'Flora');
        final repository = _QueuedStopsRepository(
          const [
            StopsPage(
              stops: [_andel],
              limit: gtfsCompleteStopsPageLimit,
              offset: 0,
              rawReturnedCount: gtfsCompleteStopsPageLimit,
              hasMore: true,
            ),
            StopsPage(
              stops: [flora],
              limit: gtfsCompleteStopsPageLimit,
              offset: gtfsCompleteStopsPageLimit,
              rawReturnedCount: 1,
              hasMore: false,
            ),
          ],
        );
        final useCase = LoadCompleteStopIndexUseCase(
          GetStopsUseCase(repository),
        );

        final result = await useCase();

        expect(
          repository.queries.map((query) => query.limit),
          [gtfsCompleteStopsPageLimit, gtfsCompleteStopsPageLimit],
        );
        expect(
          repository.queries.map((query) => query.offset),
          [0, gtfsCompleteStopsPageLimit],
        );
        expect(result.stops, const [_andel, flora]);
        expect(result.rawReturnedCount, gtfsCompleteStopsPageLimit + 1);
        expect(result.hasMore, isFalse);
      },
    );

    test('complete index loader stops when a page has zero raw rows', () async {
      final repository = _QueuedStopsRepository(
        const [
          StopsPage(
            stops: [],
            limit: gtfsCompleteStopsPageLimit,
            offset: 0,
            rawReturnedCount: 0,
            hasMore: true,
          ),
        ],
      );
      final useCase = LoadCompleteStopIndexUseCase(GetStopsUseCase(repository));

      final result = await useCase();

      expect(repository.queries, hasLength(1));
      expect(repository.queries.single.limit, gtfsCompleteStopsPageLimit);
      expect(repository.queries.single.offset, 0);
      expect(result.stops, isEmpty);
      expect(result.rawReturnedCount, 0);
      expect(result.hasMore, isFalse);
    });

    test(
      'complete index loader attaches parent aliases across pages',
      () async {
        const hlavniNadrazi = Stop(
          id: 'U202Z101P',
          name: 'Hlavní nádraží',
          parentStationId: 'U202S1',
        );
        final repository = _QueuedStopsRepository(
          const [
            StopsPage(
              stops: [hlavniNadrazi],
              limit: gtfsCompleteStopsPageLimit,
              offset: 0,
              rawReturnedCount: gtfsCompleteStopsPageLimit,
              hasMore: true,
            ),
            StopsPage(
              stops: [],
              limit: gtfsCompleteStopsPageLimit,
              offset: gtfsCompleteStopsPageLimit,
              rawReturnedCount: 1,
              hasMore: false,
              parentStationNamesById: {'U202S1': 'Praha hlavní nádraží'},
            ),
          ],
        );
        final useCase = LoadCompleteStopIndexUseCase(
          GetStopsUseCase(repository),
        );

        final result = await useCase();

        expect(result.stops.single.searchAliases, ['Praha hlavní nádraží']);
        expect(result.parentStationNamesById, {
          'U202S1': 'Praha hlavní nádraží',
        });
      },
    );

    test('cache use cases read and write cache snapshots', () async {
      final repository = _MemoryStopsCacheRepository();
      final cachedAt = DateTime.utc(2026, 6, 23, 12);

      await SaveStopsCacheUseCase(repository)(
        cachedAt: cachedAt,
        stops: const [_andel],
        hasMore: true,
        nextOffset: 500,
      );

      final cache = await LoadCachedStopsUseCase(repository)();

      expect(cache, isNotNull);
      expect(cache!.cachedAt, cachedAt);
      expect(cache.stops, const [_andel]);
      expect(cache.hasMore, isTrue);
      expect(cache.nextOffset, 500);
    });

    test('cache read failures are treated as safe cache misses', () async {
      final repository = _MemoryStopsCacheRepository(readError: _timeout);

      expect(await LoadCachedStopsUseCase(repository)(), isNull);
    });

    test('saved stops load failures return empty IDs', () async {
      final repository = _MemorySavedStopsRepository(readError: _timeout);

      final savedStops = await LoadSavedStopGroupsUseCase(repository)();

      expect(savedStops.favoriteGroupIds, isEmpty);
      expect(savedStops.recentGroupIds, isEmpty);
    });

    test('toggle favorite returns updated IDs and persists them', () async {
      final repository = _MemorySavedStopsRepository();
      final useCase = ToggleFavoriteStopUseCase(repository);
      final updatedAt = DateTime.utc(2026, 6, 23, 12);

      final added = await useCase(
        groupId: ' U123S1 ',
        currentFavoriteGroupIds: const <String>[],
        updatedAt: updatedAt,
      );
      final removed = await useCase(
        groupId: 'U123S1',
        currentFavoriteGroupIds: added,
        updatedAt: updatedAt,
      );

      expect(added, ['U123S1']);
      expect(removed, isEmpty);
      expect(repository.favoriteGroupIds, isEmpty);
      expect(repository.favoriteUpdatedAt, updatedAt);
    });

    test('record recent moves existing IDs to top and caps list', () async {
      final repository = _MemorySavedStopsRepository();
      final useCase = RecordRecentStopUseCase(repository);
      final updatedAt = DateTime.utc(2026, 6, 23, 12);
      var recentGroupIds = const <String>[];

      for (var index = 0; index < maxRecentStopGroupsCount + 2; index++) {
        recentGroupIds = await useCase(
          groupId: 'U$index',
          currentRecentGroupIds: recentGroupIds,
          updatedAt: updatedAt,
        );
      }
      recentGroupIds = await useCase(
        groupId: 'U5',
        currentRecentGroupIds: recentGroupIds,
        updatedAt: updatedAt,
      );

      expect(recentGroupIds, hasLength(maxRecentStopGroupsCount));
      expect(recentGroupIds.first, 'U5');
      expect(recentGroupIds.last, 'U2');
      expect(recentGroupIds, isNot(contains('U0')));
      expect(recentGroupIds, isNot(contains('U1')));
      expect(repository.recentGroupIds, recentGroupIds);
      expect(repository.recentUpdatedAt, updatedAt);
    });
  });
}

const _timeout = AppException(
  type: AppExceptionType.timeout,
  message: 'Timeout.',
);

const _andel = Stop(id: 'U123Z1', name: 'Andel');

class _RecordingStopsRepository implements PaginatedStopsRepository {
  final queries = <GtfsStopsQuery>[];

  @override
  Future<List<Stop>> fetchStops() async {
    return const <Stop>[];
  }

  @override
  Future<StopsPage> fetchStopsPage(GtfsStopsQuery query) async {
    queries.add(query);

    return StopsPage(
      stops: const <Stop>[],
      limit: query.limit ?? 0,
      offset: query.offset ?? 0,
      rawReturnedCount: 0,
      hasMore: false,
    );
  }
}

class _QueuedStopsRepository implements PaginatedStopsRepository {
  _QueuedStopsRepository(this._pages);

  final List<StopsPage> _pages;
  final queries = <GtfsStopsQuery>[];

  @override
  Future<List<Stop>> fetchStops() async {
    return _pages.first.stops;
  }

  @override
  Future<StopsPage> fetchStopsPage(GtfsStopsQuery query) async {
    queries.add(query);
    return _pages[queries.length - 1];
  }
}

class _MemoryStopsCacheRepository implements StopsCacheRepository {
  _MemoryStopsCacheRepository({this.readError});

  final Object? readError;
  StopsCacheSnapshot? cache;

  @override
  Future<StopsCacheSnapshot?> read() async {
    final readError = this.readError;
    if (readError != null) {
      throw Exception(readError);
    }

    return cache;
  }

  @override
  Future<void> write(StopsCacheSnapshot cache) async {
    this.cache = cache;
  }

  @override
  Future<void> clear() async {
    cache = null;
  }
}

class _MemorySavedStopsRepository implements SavedStopsRepository {
  _MemorySavedStopsRepository({this.readError});

  final Object? readError;
  List<String> favoriteGroupIds = const <String>[];
  List<String> recentGroupIds = const <String>[];
  DateTime? favoriteUpdatedAt;
  DateTime? recentUpdatedAt;

  @override
  Future<SavedStopGroups> read() async {
    final readError = this.readError;
    if (readError != null) {
      throw Exception(readError);
    }

    return SavedStopGroups(
      favoriteGroupIds: favoriteGroupIds,
      recentGroupIds: recentGroupIds,
    );
  }

  @override
  Future<void> writeFavoriteGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  }) async {
    favoriteGroupIds = groupIds;
    favoriteUpdatedAt = updatedAt;
  }

  @override
  Future<void> writeRecentGroupIds({
    required List<String> groupIds,
    required DateTime updatedAt,
  }) async {
    recentGroupIds = groupIds;
    recentUpdatedAt = updatedAt;
  }
}
