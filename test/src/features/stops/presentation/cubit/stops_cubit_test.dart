import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';
import 'package:pid_oict/src/features/stops/data/models/saved_stops.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state.dart';

import '../../../../../helpers/in_memory_saved_stops_data_source.dart';
import '../../../../../helpers/in_memory_stops_cache_data_source.dart';

void main() {
  group('StopsCubit', () {
    test('loads stops successfully', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.allStops, hasLength(2));
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Staromestska',
      ]);
      expect(repository.callCount, 1);
    });

    test('stores error when initial load fails', () async {
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _FakeStopsRepository([
        const _StopsFailure(expectedError),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.error);
      expect(cubit.state.error, same(expectedError));
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('retry reloads after error', () async {
      final repository = _FakeStopsRepository([
        const _StopsFailure(
          AppException(type: AppExceptionType.timeout, message: 'Timeout.'),
        ),
        const _StopsSuccess([Stop(id: '1', name: 'Andel')]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.retry();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredStops.single.name, 'Andel');
      expect(repository.callCount, 2);
    });

    test('empty API result becomes empty state', () async {
      final repository = _FakeStopsRepository([const _StopsSuccess([])]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.empty);
      expect(cubit.state.allStops, isEmpty);
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('search filters already loaded stops', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('and');

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.searchQuery, 'and');
      expect(cubit.state.filteredStops.map((stop) => stop.name), ['Andel']);
    });

    test('search with no matching result becomes empty search state', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('airport');

      expect(cubit.state.status, StopsStatus.empty);
      expect(cubit.state.searchQuery, 'airport');
      expect(cubit.state.filteredStops, isEmpty);
    });

    test('search query changes do not call repository again', () async {
      final repository = _FakeStopsRepository([
        const _StopsSuccess([
          Stop(id: '1', name: 'Andel'),
          Stop(id: '2', name: 'Staromestska'),
        ]),
      ]);
      final cubit = _createCubit(repository);
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit
        ..searchChanged('and')
        ..searchChanged('star')
        ..clearSearch();

      expect(repository.callCount, 1);
      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredStops, hasLength(2));
    });

    test('loads first page with pagination metadata', () async {
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(id: 'U2Z1', name: 'Flora'),
              Stop(id: 'U1Z1', name: 'Andel'),
            ],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: true,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        pageSize: 2,
        searchDebounceDuration: Duration.zero,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(repository.queries.single.limit, 2);
      expect(repository.queries.single.offset, 0);
      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Flora',
      ]);
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.nextOffset, 2);
    });

    test('initial load exposes grouped public stops', () async {
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(
                id: 'U118Z101P',
                name: 'Flora',
                platformCode: 'A',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
              Stop(
                id: 'U118Z102P',
                name: 'Flora',
                platformCode: 'B',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
            ],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(GetStopsUseCase(repository), pageSize: 2);
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.single.name, 'Flora');
      expect(cubit.state.filteredGroups.single.stopIds, [
        'U118Z101P',
        'U118Z102P',
      ]);
      expect(cubit.state.filteredGroups.single.platformCodes, ['A', 'B']);
      expect(cubit.state.filteredStops.single.id, 'U118Z101P');
    });

    test('load more appends pages and deduplicates by stop id', () async {
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(id: 'U2Z1', name: 'Flora'),
              Stop(id: 'U1Z1', name: 'Andel'),
            ],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(id: 'U2Z1', name: 'Flora updated'),
              Stop(id: 'U3Z1', name: 'I. P. Pavlova'),
            ],
            limit: 2,
            offset: 2,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(GetStopsUseCase(repository), pageSize: 2);
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.loadMore();

      expect(repository.queries.map((query) => query.offset), [0, 2]);
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Flora updated',
        'I. P. Pavlova',
      ]);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.nextOffset, 3);
    });

    test('load more combines grouped platforms from later pages', () async {
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(
                id: 'U118Z101P',
                name: 'Flora',
                platformCode: 'A',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
            ],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(
                id: 'U118Z102P',
                name: 'Flora',
                platformCode: 'B',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
            ],
            limit: 1,
            offset: 1,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(GetStopsUseCase(repository), pageSize: 1);
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.loadMore();

      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.single.stopIds, [
        'U118Z101P',
        'U118Z102P',
      ]);
      expect(cubit.state.filteredGroups.single.platformCodes, ['A', 'B']);
      expect(cubit.state.hasMore, isFalse);
    });

    test(
      'load more is ignored while a page request is already running',
      () async {
        final completer = Completer<StopsPage>();
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [Stop(id: 'U1Z1', name: 'Andel')],
              limit: 1,
              offset: 0,
              rawReturnedCount: 1,
              hasMore: true,
            ),
          ),
          _StopsPagePending(completer),
        ]);
        final cubit = StopsCubit(GetStopsUseCase(repository), pageSize: 1);
        addTearDown(cubit.close);

        await cubit.loadStops();
        final firstLoadMore = cubit.loadMore();
        await Future<void>.delayed(Duration.zero);
        await cubit.loadMore();

        expect(repository.queries.map((query) => query.offset), [0, 1]);
        completer.complete(
          const StopsPage(
            stops: [Stop(id: 'U2Z1', name: 'Flora')],
            limit: 1,
            offset: 1,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        );
        await firstLoadMore;

        expect(cubit.state.filteredStops.map((stop) => stop.name), [
          'Andel',
          'Flora',
        ]);
      },
    );

    test(
      'search with three characters uses API names query after debounce',
      () async {
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [
                Stop(id: 'U1Z1', name: 'Andel'),
                Stop(id: 'U2Z1', name: 'Flora'),
              ],
              limit: 2,
              offset: 0,
              rawReturnedCount: 2,
              hasMore: true,
            ),
          ),
          const _StopsPageSuccess(
            StopsPage(
              stops: [Stop(id: 'U2Z1', name: 'Flora')],
              limit: 100,
              offset: 0,
              rawReturnedCount: 1,
              hasMore: false,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          pageSize: 2,
          searchDebounceDuration: Duration.zero,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();
        cubit.searchChanged('Flo');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(repository.queries, hasLength(2));
        expect(repository.queries.last.names, ['Flo']);
        expect(repository.queries.last.limit, gtfsStopsSearchLimit);
        expect(repository.queries.last.offset, 0);
        expect(cubit.state.isSearching, isFalse);
        expect(cubit.state.filteredStops.single.name, 'Flora');
        expect(cubit.state.hasMore, isTrue);
      },
    );

    test('API search results are grouped before display', () async {
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(id: 'U1Z1', name: 'Andel'),
              Stop(id: 'U2Z1', name: 'Flora'),
            ],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [
              Stop(
                id: 'U118Z101P',
                name: 'Flora',
                platformCode: 'A',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
              Stop(
                id: 'U118Z102P',
                name: 'Flora',
                platformCode: 'B',
                zoneId: 'P',
                parentStationId: 'U118S1',
              ),
            ],
            limit: 100,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        pageSize: 2,
        searchDebounceDuration: Duration.zero,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('Flo');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.single.name, 'Flora');
      expect(cubit.state.filteredGroups.single.stopIds, [
        'U118Z101P',
        'U118Z102P',
      ]);
      expect(cubit.state.filteredGroups.single.platformCodes, ['A', 'B']);
    });

    test(
      'API search empty result keeps diacritics-insensitive local matches',
      () async {
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [_cernyMostPublicStop],
              limit: 1,
              offset: 0,
              rawReturnedCount: 1,
              hasMore: true,
            ),
          ),
          const _StopsPageSuccess(
            StopsPage(
              stops: [],
              limit: 100,
              offset: 0,
              rawReturnedCount: 0,
              hasMore: false,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          pageSize: 1,
          searchDebounceDuration: Duration.zero,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();
        cubit.searchChanged('cer');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(repository.queries, hasLength(2));
        expect(repository.queries.last.names, ['cer']);
        expect(cubit.state.status, StopsStatus.loaded);
        expect(cubit.state.isSearching, isFalse);
        expect(cubit.state.filteredGroups.map((group) => group.name), [
          'Černý Most',
        ]);
      },
    );

    test(
      'short search query stays local and does not call API search',
      () async {
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [
                Stop(id: 'U1Z1', name: 'Andel'),
                Stop(id: 'U2Z1', name: 'Flora'),
              ],
              limit: 2,
              offset: 0,
              rawReturnedCount: 2,
              hasMore: true,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          pageSize: 2,
          searchDebounceDuration: Duration.zero,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();
        cubit.searchChanged('an');
        await Future<void>.delayed(Duration.zero);

        expect(repository.queries, hasLength(1));
        expect(cubit.state.filteredStops.single.name, 'Andel');
      },
    );

    test('writes cache after network-first load succeeds', () async {
      final cache = InMemoryStopsCacheDataSource();
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_andelPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: true,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        pageSize: 1,
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      final writtenCache = await cache.read();
      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.isFromCache, isFalse);
      expect(writtenCache, isNotNull);
      expect(writtenCache!.cachedAt, _now);
      expect(writtenCache.stops.single.id, _andelPublicStop.id);
      expect(writtenCache.hasMore, isTrue);
      expect(writtenCache.nextOffset, 1);
    });

    test('keeps full error state when no cache and network fails', () async {
      final cache = InMemoryStopsCacheDataSource();
      const expectedError = AppException(
        type: AppExceptionType.network,
        message: 'Network failed.',
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageFailure(expectedError),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.error);
      expect(cubit.state.error, same(expectedError));
      expect(await cache.read(), isNull);
    });

    test('emits fresh cache before background refresh completes', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(const Duration(hours: 1)),
          stops: const [_andelPublicStop],
          hasMore: true,
          nextOffset: 500,
        ),
      );
      final completer = Completer<StopsPage>();
      final repository = _FakePaginatedStopsRepository([
        _StopsPagePending(completer),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      final loadFuture = cubit.loadStops();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.isFromCache, isTrue);
      expect(cubit.state.isCacheStale, isFalse);
      expect(cubit.state.filteredGroups.single.name, 'Andel');
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.nextOffset, 500);

      completer.complete(
        const StopsPage(
          stops: [_floraPublicStop],
          limit: 1,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
      );
      await loadFuture;

      expect(cubit.state.isFromCache, isFalse);
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Flora',
      ]);
    });

    test('background refresh failure keeps cached groups visible', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(const Duration(hours: 1)),
          stops: const [_andelPublicStop],
        ),
      );
      const expectedError = AppException(
        type: AppExceptionType.timeout,
        message: 'Timeout.',
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageFailure(expectedError),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredGroups.single.name, 'Andel');
      expect(cubit.state.isFromCache, isTrue);
      expect(cubit.state.cacheRefreshError, same(expectedError));
      expect(cubit.state.hasCacheWarning, isTrue);
    });

    test('stale cache emits stale flag before refresh', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(stopsCacheTtl + const Duration(minutes: 1)),
          stops: const [_andelPublicStop],
        ),
      );
      final completer = Completer<StopsPage>();
      final repository = _FakePaginatedStopsRepository([
        _StopsPagePending(completer),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      final loadFuture = cubit.loadStops();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.isFromCache, isTrue);
      expect(cubit.state.isCacheStale, isTrue);
      expect(cubit.state.hasCacheWarning, isTrue);

      completer.complete(
        const StopsPage(
          stops: [_floraPublicStop],
          limit: 1,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
      );
      await loadFuture;
    });

    test('stale cache refresh success clears stale flag', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(stopsCacheTtl + const Duration(minutes: 1)),
          stops: const [_andelPublicStop],
        ),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.isFromCache, isFalse);
      expect(cubit.state.isCacheStale, isFalse);
      expect(cubit.state.cacheRefreshError, isNull);
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Flora',
      ]);
    });

    test('stale cache refresh failure keeps stale warning', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now.subtract(stopsCacheTtl + const Duration(minutes: 1)),
          stops: const [_andelPublicStop],
        ),
      );
      const expectedError = AppException(
        type: AppExceptionType.timeout,
        message: 'Timeout.',
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageFailure(expectedError),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.isFromCache, isTrue);
      expect(cubit.state.isCacheStale, isTrue);
      expect(cubit.state.cacheRefreshError, same(expectedError));
      expect(cubit.state.filteredGroups.single.name, 'Andel');
    });

    test('load more updates cache through stop id merge', () async {
      final cache = InMemoryStopsCacheDataSource();
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_andelPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 1,
            offset: 1,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        pageSize: 1,
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.loadMore();

      final writtenCache = await cache.read();
      expect(writtenCache, isNotNull);
      expect(writtenCache!.stops.map((stop) => stop.id), [
        _andelPublicStop.id,
        _floraPublicStop.id,
      ]);
      expect(writtenCache.hasMore, isFalse);
      expect(writtenCache.nextOffset, 2);
    });

    test('API search does not overwrite the full cache', () async {
      final cache = InMemoryStopsCacheDataSource();
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_andelPublicStop, _staromestskaPublicStop],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 100,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        pageSize: 2,
        searchDebounceDuration: Duration.zero,
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('Flo');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final writtenCache = await cache.read();
      expect(cubit.state.filteredGroups.single.name, 'Flora');
      expect(writtenCache!.stops.map((stop) => stop.id), [
        _andelPublicStop.id,
        _staromestskaPublicStop.id,
      ]);
    });

    test('short local search works over cached groups', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now,
          stops: const [_andelPublicStop, _staromestskaPublicStop],
        ),
      );
      final completer = Completer<StopsPage>();
      final repository = _FakePaginatedStopsRepository([
        _StopsPagePending(completer),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      final loadFuture = cubit.loadStops();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      cubit.searchChanged('and');

      expect(cubit.state.status, StopsStatus.loaded);
      expect(cubit.state.filteredGroups.single.name, 'Andel');

      completer.complete(
        const StopsPage(
          stops: [_floraPublicStop],
          limit: 1,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
      );
      await loadFuture;
    });

    test('cached stops rebuild stop groups', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now,
          stops: const [_floraPublicStop, _floraPlatformBPublicStop],
        ),
      );
      final completer = Completer<StopsPage>();
      final repository = _FakePaginatedStopsRepository([
        _StopsPagePending(completer),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      final loadFuture = cubit.loadStops();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.filteredGroups, hasLength(1));
      expect(cubit.state.filteredGroups.single.name, 'Flora');
      expect(cubit.state.filteredGroups.single.stopIds, [
        _floraPublicStop.id,
        _floraPlatformBPublicStop.id,
      ]);
      expect(cubit.state.filteredGroups.single.platformCodes, ['A', 'B']);

      completer.complete(
        const StopsPage(
          stops: [_andelPublicStop],
          limit: 1,
          offset: 0,
          rawReturnedCount: 1,
          hasMore: false,
        ),
      );
      await loadFuture;
    });

    test('load more works after cached startup', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(
          cachedAt: _now,
          stops: const [_andelPublicStop],
          hasMore: true,
          nextOffset: 500,
        ),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 500,
            offset: 0,
            rawReturnedCount: 500,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [_staromestskaPublicStop],
            limit: 500,
            offset: 500,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();
      await cubit.loadMore();

      expect(repository.queries.map((query) => query.offset), [0, 500]);
      expect(cubit.state.filteredGroups.map((group) => group.name), [
        'Andel',
        'Flora',
        'Staromestska',
      ]);
      final writtenCache = await cache.read();
      expect(writtenCache!.stops.map((stop) => stop.id), [
        _andelPublicStop.id,
        _floraPublicStop.id,
        _staromestskaPublicStop.id,
      ]);
    });

    test(
      'loads favorite IDs from storage and resolves loaded groups',
      () async {
        final savedStops = InMemorySavedStopsDataSource();
        await savedStops.writeFavorites(
          FavoriteStops(
            updatedAt: _now,
            favoriteGroupIds: const ['U123S1', 'missing-group'],
          ),
        );
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [_andelPublicStop],
              limit: 1,
              offset: 0,
              rawReturnedCount: 1,
              hasMore: false,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          savedStopsDataSource: savedStops,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();

        expect(cubit.state.favoriteGroupIds, ['U123S1', 'missing-group']);
        expect(cubit.state.favoriteGroups.map((group) => group.id), ['U123S1']);
        expect(
          cubit.state.isFavorite(cubit.state.filteredGroups.single),
          isTrue,
        );
      },
    );

    test('loads recent IDs from storage and resolves loaded groups', () async {
      final savedStops = InMemorySavedStopsDataSource();
      await savedStops.writeRecent(
        RecentStops(
          updatedAt: _now,
          recentGroupIds: const ['U456S1', 'missing-group'],
        ),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_staromestskaPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        savedStopsDataSource: savedStops,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.recentGroupIds, ['U456S1', 'missing-group']);
      expect(cubit.state.recentGroups.map((group) => group.id), ['U456S1']);
    });

    test(
      'toggle favorite adds and removes ID without changing recent',
      () async {
        final savedStops = InMemorySavedStopsDataSource();
        await savedStops.writeRecent(
          RecentStops(updatedAt: _now, recentGroupIds: const ['U118S1']),
        );
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [_andelPublicStop],
              limit: 1,
              offset: 0,
              rawReturnedCount: 1,
              hasMore: false,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          savedStopsDataSource: savedStops,
          now: () => _now,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();
        final group = cubit.state.filteredGroups.single;
        await cubit.toggleFavorite(group);

        expect(cubit.state.favoriteGroupIds, ['U123S1']);
        expect((await savedStops.readFavorites()).favoriteGroupIds, ['U123S1']);
        expect((await savedStops.readRecent()).recentGroupIds, ['U118S1']);

        await cubit.toggleFavorite(group);

        expect(cubit.state.favoriteGroupIds, isEmpty);
        expect((await savedStops.readFavorites()).favoriteGroupIds, isEmpty);
        expect((await savedStops.readRecent()).recentGroupIds, ['U118S1']);
      },
    );

    test(
      'record recent writes newest-first order and moves existing to top',
      () async {
        final savedStops = InMemorySavedStopsDataSource();
        final repository = _FakePaginatedStopsRepository([
          const _StopsPageSuccess(
            StopsPage(
              stops: [_andelPublicStop, _floraPublicStop],
              limit: 2,
              offset: 0,
              rawReturnedCount: 2,
              hasMore: false,
            ),
          ),
        ]);
        final cubit = StopsCubit(
          GetStopsUseCase(repository),
          savedStopsDataSource: savedStops,
          now: () => _now,
        );
        addTearDown(cubit.close);

        await cubit.loadStops();
        final groupsByName = {
          for (final group in cubit.state.filteredGroups) group.name: group,
        };
        await cubit.recordRecentStop(groupsByName['Andel']!);
        await cubit.recordRecentStop(groupsByName['Flora']!);
        await cubit.recordRecentStop(groupsByName['Andel']!);

        expect(cubit.state.recentGroupIds, ['U123S1', 'U118S1']);
        expect((await savedStops.readRecent()).recentGroupIds, [
          'U123S1',
          'U118S1',
        ]);
      },
    );

    test('record recent enforces max count', () async {
      final savedStops = InMemorySavedStopsDataSource();
      final cubit = StopsCubit(
        GetStopsUseCase(_FakePaginatedStopsRepository(const [])),
        savedStopsDataSource: savedStops,
        now: () => _now,
      );
      addTearDown(cubit.close);

      for (var index = 0; index < maxRecentStopsCount + 2; index++) {
        await cubit.recordRecentStop(_stopGroup(index));
      }

      expect(cubit.state.recentGroupIds, hasLength(maxRecentStopsCount));
      expect(cubit.state.recentGroupIds.first, 'U11S1');
      expect(cubit.state.recentGroupIds.last, 'U2S1');
      expect((await savedStops.readRecent()).recentGroupIds, hasLength(10));
    });

    test('API search keeps favorite and recent IDs', () async {
      final savedStops = InMemorySavedStopsDataSource();
      await savedStops.writeFavorites(
        FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U123S1']),
      );
      await savedStops.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['U456S1']),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_andelPublicStop, _staromestskaPublicStop],
            limit: 2,
            offset: 0,
            rawReturnedCount: 2,
            hasMore: true,
          ),
        ),
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 100,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        savedStopsDataSource: savedStops,
        searchDebounceDuration: Duration.zero,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();
      cubit.searchChanged('Flo');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.favoriteGroupIds, ['U123S1']);
      expect(cubit.state.recentGroupIds, ['U456S1']);
      expect(cubit.state.favoriteGroups, isEmpty);
      expect(cubit.state.recentGroups, isEmpty);
    });

    test('cache refresh keeps favorite and recent IDs', () async {
      final cache = InMemoryStopsCacheDataSource();
      await cache.write(
        CachedStops(cachedAt: _now, stops: const [_andelPublicStop]),
      );
      final savedStops = InMemorySavedStopsDataSource();
      await savedStops.writeFavorites(
        FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['U123S1']),
      );
      await savedStops.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['U123S1']),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_floraPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        cacheDataSource: cache,
        savedStopsDataSource: savedStops,
        now: () => _now,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.favoriteGroupIds, ['U123S1']);
      expect(cubit.state.recentGroupIds, ['U123S1']);
      expect(cubit.state.favoriteGroups.map((group) => group.id), ['U123S1']);
      expect(cubit.state.recentGroups.map((group) => group.id), ['U123S1']);
    });

    test('unknown favorite and recent IDs are tolerated safely', () async {
      final savedStops = InMemorySavedStopsDataSource();
      await savedStops.writeFavorites(
        FavoriteStops(updatedAt: _now, favoriteGroupIds: const ['unknown']),
      );
      await savedStops.writeRecent(
        RecentStops(updatedAt: _now, recentGroupIds: const ['unknown']),
      );
      final repository = _FakePaginatedStopsRepository([
        const _StopsPageSuccess(
          StopsPage(
            stops: [_andelPublicStop],
            limit: 1,
            offset: 0,
            rawReturnedCount: 1,
            hasMore: false,
          ),
        ),
      ]);
      final cubit = StopsCubit(
        GetStopsUseCase(repository),
        savedStopsDataSource: savedStops,
      );
      addTearDown(cubit.close);

      await cubit.loadStops();

      expect(cubit.state.favoriteGroupIds, ['unknown']);
      expect(cubit.state.recentGroupIds, ['unknown']);
      expect(cubit.state.favoriteGroups, isEmpty);
      expect(cubit.state.recentGroups, isEmpty);
    });
  });
}

final _now = DateTime.utc(2026, 6, 23, 12);

const _andelPublicStop = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U123S1',
  latitude: 50.07128,
  longitude: 14.40312,
);

const _staromestskaPublicStop = Stop(
  id: 'U456Z2',
  name: 'Staromestska',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U456S1',
  latitude: 50.08708,
  longitude: 14.42078,
);

const _floraPublicStop = Stop(
  id: 'U118Z101P',
  name: 'Flora',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07827,
  longitude: 14.4633,
);

const _floraPlatformBPublicStop = Stop(
  id: 'U118Z102P',
  name: 'Flora',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U118S1',
  latitude: 50.07831,
  longitude: 14.4631,
);

const _cernyMostPublicStop = Stop(
  id: 'U122Z101P',
  name: 'Černý Most',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U122S1',
  latitude: 50.10878,
  longitude: 14.57792,
);

StopGroup _stopGroup(int index) {
  return StopGroup.single(
    Stop(
      id: 'U${index}Z1',
      name: 'Stop $index',
      platformCode: 'A',
      zoneId: 'P',
      locationType: 0,
      parentStationId: 'U${index}S1',
      latitude: 50,
      longitude: 14,
    ),
  );
}

StopsCubit _createCubit(_FakeStopsRepository repository) {
  return StopsCubit(GetStopsUseCase(repository));
}

class _FakeStopsRepository implements StopsRepository {
  _FakeStopsRepository(this._responses);

  final List<_StopsResponse> _responses;
  int callCount = 0;

  @override
  Future<List<Stop>> fetchStops() async {
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _StopsSuccess(:final stops) => stops,
      _StopsFailure(:final error) => _throwTestError(error),
    };
  }
}

class _FakePaginatedStopsRepository implements PaginatedStopsRepository {
  _FakePaginatedStopsRepository(this._responses);

  final List<_StopsPageResponse> _responses;
  final queries = <GtfsStopsQuery>[];

  @override
  Future<List<Stop>> fetchStops() async {
    final page = await fetchStopsPage(
      const GtfsStopsQuery(limit: gtfsStopsPageSize, offset: 0),
    );

    return page.stops;
  }

  @override
  Future<StopsPage> fetchStopsPage(GtfsStopsQuery query) async {
    if (queries.length >= _responses.length) {
      throw StateError(
        'No fake stops page response at index ${queries.length}.',
      );
    }

    final response = _responses[queries.length];
    queries.add(query);

    return switch (response) {
      _StopsPageSuccess(:final page) => page,
      _StopsPageFailure(:final error) => _throwTestError(error),
      _StopsPagePending(:final completer) => completer.future,
    };
  }
}

Never _throwTestError(Object error) {
  if (error is Exception) {
    throw error;
  }

  if (error is Error) {
    throw error;
  }

  throw StateError(error.toString());
}

sealed class _StopsResponse {
  const _StopsResponse();
}

class _StopsSuccess extends _StopsResponse {
  const _StopsSuccess(this.stops);

  final List<Stop> stops;
}

class _StopsFailure extends _StopsResponse {
  const _StopsFailure(this.error);

  final Object error;
}

sealed class _StopsPageResponse {
  const _StopsPageResponse();
}

class _StopsPageSuccess extends _StopsPageResponse {
  const _StopsPageSuccess(this.page);

  final StopsPage page;
}

class _StopsPageFailure extends _StopsPageResponse {
  const _StopsPageFailure(this.error);

  final Object error;
}

class _StopsPagePending extends _StopsPageResponse {
  const _StopsPagePending(this.completer);

  final Completer<StopsPage> completer;
}
