import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stops_page.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_cubit.dart';
import 'package:pid_oict/src/features/stops/presentation/cubit/stops_state.dart';

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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
          _StopsPageSuccess(
            const StopsPage(
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
          _StopsPageSuccess(
            const StopsPage(
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
          _StopsPageSuccess(
            const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
        _StopsPageSuccess(
          const StopsPage(
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
      'short search query stays local and does not call API search',
      () async {
        final repository = _FakePaginatedStopsRepository([
          _StopsPageSuccess(
            const StopsPage(
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
  });
}

StopsCubit _createCubit(_FakeStopsRepository repository) {
  return StopsCubit(GetStopsUseCase(repository));
}

class _FakeStopsRepository implements StopsRepository {
  _FakeStopsRepository(this._responses);

  final List<_StopsResponse> _responses;
  var callCount = 0;

  @override
  Future<List<Stop>> fetchStops() async {
    final response = _responses[callCount];
    callCount++;

    return switch (response) {
      _StopsSuccess(:final stops) => stops,
      _StopsFailure(:final error) => throw error,
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
      _StopsPageFailure(:final error) => throw error,
      _StopsPagePending(:final completer) => completer.future,
    };
  }
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
