import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/saved_stop_groups.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
import '../../domain/stop_visibility.dart';
import '../../domain/stops_cache_snapshot.dart';
import '../../domain/usecases/get_stops_use_case.dart';
import '../../domain/usecases/load_cached_stops_use_case.dart';
import '../../domain/usecases/load_saved_stop_groups_use_case.dart';
import '../../domain/usecases/load_stop_groups_use_case.dart';
import '../../domain/usecases/record_recent_stop_use_case.dart';
import '../../domain/usecases/refresh_stop_groups_use_case.dart';
import '../../domain/usecases/save_stops_cache_use_case.dart';
import '../../domain/usecases/search_stop_groups_use_case.dart';
import '../../domain/usecases/toggle_favorite_stop_use_case.dart';
import 'stops_search_coordinator.dart';
import 'stops_sorting.dart';
import 'stops_state.dart';
import 'stops_state_factory.dart';

const gtfsStopsPageSize = 500;
const gtfsStopsSearchLimit = 100;
const minGtfsStopsApiSearchLength = 3;
const gtfsStopsSearchDebounceDuration = Duration(milliseconds: 350);

class StopsCubit extends Cubit<StopsState> {
  StopsCubit(
    GetStopsUseCase getStops, {
    this.pageSize = gtfsStopsPageSize,
    this.searchLimit = gtfsStopsSearchLimit,
    this.searchDebounceDuration = gtfsStopsSearchDebounceDuration,
    LoadStopGroupsUseCase? loadStopGroups,
    RefreshStopGroupsUseCase? refreshStopGroups,
    SearchStopGroupsUseCase? searchStopGroups,
    this.loadCachedStops,
    this.saveStopsCache,
    this.loadSavedStopGroups,
    this.toggleFavoriteStop,
    this.recordRecentStopUseCase,
    StopsSearchCoordinator? searchCoordinator,
    DateTime Function()? now,
  }) : _loadStopGroups = loadStopGroups ?? LoadStopGroupsUseCase(getStops),
       _refreshStopGroups =
           refreshStopGroups ?? RefreshStopGroupsUseCase(getStops),
       _searchStopGroups =
           searchStopGroups ??
           SearchStopGroupsUseCase(
             getStops,
           ),
       _now = now ?? DateTime.now,
       super(const StopsState.loading()) {
    _searchCoordinator =
        searchCoordinator ??
        StopsSearchCoordinator(
          searchStops: _searchStopGroups.call,
          searchLimit: searchLimit,
          minApiSearchLength: minGtfsStopsApiSearchLength,
        );
  }

  final LoadStopGroupsUseCase _loadStopGroups;
  final RefreshStopGroupsUseCase _refreshStopGroups;
  final SearchStopGroupsUseCase _searchStopGroups;
  final StopsStateFactory _stateFactory = const StopsStateFactory();
  final LoadCachedStopsUseCase? loadCachedStops;
  final SaveStopsCacheUseCase? saveStopsCache;
  final LoadSavedStopGroupsUseCase? loadSavedStopGroups;
  final ToggleFavoriteStopUseCase? toggleFavoriteStop;
  final RecordRecentStopUseCase? recordRecentStopUseCase;
  final DateTime Function() _now;
  final int pageSize;
  final int searchLimit;
  final Duration searchDebounceDuration;
  late final StopsSearchCoordinator _searchCoordinator;
  final _stopsById = <String, Stop>{};
  var _favoriteGroupIds = const <String>[];
  var _recentGroupIds = const <String>[];

  Timer? _searchDebounceTimer;
  var _initialRefreshInProgress = false;

  Future<void> loadStops() async {
    _searchDebounceTimer?.cancel();
    _stopsById.clear();
    _searchCoordinator.resetLastRequestedSearch();

    await _readSavedStops();

    final cache = await _readCache();
    if (cache != null && cache.stops.isNotEmpty) {
      final cachedPublicStops = sortedUserFacingStops(cache.stops);
      if (cachedPublicStops.isNotEmpty) {
        _upsertStops(cachedPublicStops);
        emit(
          _stateFromStops(
            _sortedStops,
            searchQuery: '',
            hasMore: cache.hasMore,
            nextOffset: cache.nextOffset,
            isFromCache: true,
            isCacheStale: !cache.isFresh(_now()),
          ),
        );

        await _refreshAfterCachedLoad();
        return;
      }
    }

    await _loadNetworkFirst();
  }

  Future<void> _loadNetworkFirst() async {
    emit(
      _stateFactory.loading(
        favoriteGroupIds: _favoriteGroupIds,
        recentGroupIds: _recentGroupIds,
      ),
    );

    try {
      final page = await _refreshStopGroups(limit: pageSize);
      _upsertStops(page.stops);
      emit(
        _stateFromStops(
          _sortedStops,
          searchQuery: '',
          hasMore: page.hasMore,
          nextOffset: page.offset + page.rawReturnedCount,
        ),
      );
      await _writeCacheFromCurrentStops(
        hasMore: page.hasMore,
        nextOffset: page.offset + page.rawReturnedCount,
      );
    } on Object catch (error) {
      emit(
        _stateFactory.initialError(
          error: AppFailure.fromObject(error),
          favoriteGroupIds: _favoriteGroupIds,
          recentGroupIds: _recentGroupIds,
        ),
      );
    }
  }

  Future<void> _refreshAfterCachedLoad() async {
    if (_initialRefreshInProgress) {
      return;
    }

    _initialRefreshInProgress = true;

    try {
      final page = await _refreshStopGroups(limit: pageSize);
      if (page.stops.isEmpty) {
        emit(
          state.copyWith(
            isLoadingMore: false,
            isSearching: false,
            clearError: true,
            clearCacheRefreshError: true,
          ),
        );
        return;
      }

      _upsertStops(page.stops);
      final nextOffset = page.offset + page.rawReturnedCount;
      emit(
        _stateFromStops(
          _sortedStops,
          searchQuery: '',
          hasMore: page.hasMore,
          nextOffset: nextOffset,
        ),
      );
      await _writeCacheFromCurrentStops(
        hasMore: page.hasMore,
        nextOffset: nextOffset,
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          isFromCache: true,
          cacheRefreshError: AppFailure.fromObject(error),
          isLoadingMore: false,
          isSearching: false,
        ),
      );
    } finally {
      _initialRefreshInProgress = false;
    }
  }

  Future<void> retry() {
    return loadStops();
  }

  Future<void> toggleFavorite(StopGroup group) async {
    final updatedAt = _now().toUtc();
    final toggleFavorite = toggleFavoriteStop;
    _favoriteGroupIds = toggleFavorite == null
        ? toggleFavoriteGroupId(_favoriteGroupIds, group.id)
        : await toggleFavorite(
            groupId: group.id,
            currentFavoriteGroupIds: _favoriteGroupIds,
            updatedAt: updatedAt,
          );
    _emitStateWithSavedStops();
  }

  Future<void> recordRecentStop(StopGroup group) async {
    final updatedAt = _now().toUtc();
    final recordRecentStop = recordRecentStopUseCase;
    _recentGroupIds = recordRecentStop == null
        ? recordRecentGroupId(_recentGroupIds, group.id)
        : await recordRecentStop(
            groupId: group.id,
            currentRecentGroupIds: _recentGroupIds,
            updatedAt: updatedAt,
          );
    _emitStateWithSavedStops();
  }

  Future<void> loadMore() async {
    final current = state;
    if (current.status == StopsStatus.loading ||
        current.status == StopsStatus.error ||
        current.isLoadingMore ||
        current.isSearching ||
        !current.hasMore ||
        _searchCoordinator.shouldUseApiSearch(current.searchQuery)) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearError: true));

    try {
      final page = await _loadStopGroups(
        limit: pageSize,
        offset: current.nextOffset,
      );
      _upsertStops(page.stops);

      emit(
        _stateFromStops(
          _sortedStops,
          searchQuery: current.searchQuery,
          hasMore: page.hasMore,
          nextOffset: current.nextOffset + page.rawReturnedCount,
          clearCacheRefreshError: true,
        ),
      );
      await _writeCacheFromCurrentStops(
        hasMore: page.hasMore,
        nextOffset: current.nextOffset + page.rawReturnedCount,
      );
    } on Object catch (error) {
      emit(
        current.copyWith(
          isLoadingMore: false,
          error: AppFailure.fromObject(error),
        ),
      );
    }
  }

  void searchChanged(String query) {
    final current = state;
    if (current.status == StopsStatus.loading ||
        current.status == StopsStatus.error) {
      return;
    }

    _searchDebounceTimer?.cancel();

    if (!_searchCoordinator.shouldUseApiSearch(query)) {
      _searchCoordinator.resetLastRequestedSearch();
      emit(
        _stateFromStops(
          _sortedStops,
          searchQuery: query,
          hasMore: current.hasMore,
          nextOffset: current.nextOffset,
          isFromCache: current.isFromCache,
          isCacheStale: current.isCacheStale,
          cacheRefreshError: current.cacheRefreshError,
        ),
      );
      return;
    }

    emit(
      _stateFromStops(
        _sortedStops,
        searchQuery: query,
        hasMore: current.hasMore,
        nextOffset: current.nextOffset,
        isSearching: true,
        isFromCache: current.isFromCache,
        isCacheStale: current.isCacheStale,
        cacheRefreshError: current.cacheRefreshError,
      ),
    );

    _searchDebounceTimer = Timer(searchDebounceDuration, () {
      unawaited(_searchStops(query));
    });
  }

  void clearSearch() {
    searchChanged('');
  }

  Future<void> _searchStops(String query) async {
    try {
      final result = await _searchCoordinator.search(
        query: query,
        loadedStops: _sortedStops,
      );
      if (result == null) {
        return;
      }

      if (state.searchQuery.trim() != result.normalizedQuery) {
        return;
      }

      if (result.useLocalFallback) {
        emit(
          _stateFromStops(
            _sortedStops,
            searchQuery: query,
            hasMore: state.hasMore,
            nextOffset: state.nextOffset,
            isFromCache: state.isFromCache,
            isCacheStale: state.isCacheStale,
            cacheRefreshError: state.cacheRefreshError,
          ),
        );
        return;
      }

      emit(
        _stateFromStops(
          result.stops,
          searchQuery: query,
          hasMore: state.hasMore,
          nextOffset: state.nextOffset,
          useProvidedStopsDirectly: true,
          isFromCache: state.isFromCache,
          isCacheStale: state.isCacheStale,
          cacheRefreshError: state.cacheRefreshError,
        ),
      );
    } on Object catch (error) {
      if (state.searchQuery.trim() != query.trim()) {
        return;
      }

      emit(
        _stateFactory.searchError(
          error: AppFailure.fromObject(error),
          allStops: _sortedStops,
          current: state,
          searchQuery: query,
          favoriteGroupIds: _favoriteGroupIds,
          recentGroupIds: _recentGroupIds,
        ),
      );
    }
  }

  StopsState _stateFromStops(
    List<Stop> stops, {
    required String searchQuery,
    required bool hasMore,
    required int nextOffset,
    bool isLoadingMore = false,
    bool isSearching = false,
    bool useProvidedStopsDirectly = false,
    bool isFromCache = false,
    bool isCacheStale = false,
    AppFailure? cacheRefreshError,
    bool clearCacheRefreshError = false,
  }) {
    return _stateFactory.fromStops(
      stops,
      searchQuery: searchQuery,
      hasMore: hasMore,
      nextOffset: nextOffset,
      isLoadingMore: isLoadingMore,
      isSearching: isSearching,
      isFromCache: isFromCache,
      isCacheStale: isCacheStale,
      cacheRefreshError: cacheRefreshError,
      clearCacheRefreshError: clearCacheRefreshError,
      favoriteGroupIds: _favoriteGroupIds,
      recentGroupIds: _recentGroupIds,
    );
  }

  Future<void> _readSavedStops() async {
    final loadSavedStopGroups = this.loadSavedStopGroups;
    if (loadSavedStopGroups == null) {
      _favoriteGroupIds = const <String>[];
      _recentGroupIds = const <String>[];
      return;
    }

    final savedStops = await loadSavedStopGroups();
    _favoriteGroupIds = savedStops.favoriteGroupIds;
    _recentGroupIds = savedStops.recentGroupIds;
  }

  void _emitStateWithSavedStops() {
    if (isClosed) {
      return;
    }

    emit(
      _stateFactory.withSavedStops(
        current: state,
        favoriteGroupIds: _favoriteGroupIds,
        recentGroupIds: _recentGroupIds,
      ),
    );
  }

  Future<StopsCacheSnapshot?> _readCache() async {
    final loadCachedStops = this.loadCachedStops;
    if (loadCachedStops == null) {
      return null;
    }

    return loadCachedStops();
  }

  Future<void> _writeCacheFromCurrentStops({
    required bool hasMore,
    required int nextOffset,
  }) async {
    final saveStopsCache = this.saveStopsCache;
    if (saveStopsCache == null) {
      return;
    }

    final publicStops = sortedUserFacingStops(_stopsById.values);
    if (publicStops.isEmpty) {
      return;
    }

    await saveStopsCache(
      cachedAt: _now().toUtc(),
      stops: publicStops,
      hasMore: hasMore,
      nextOffset: nextOffset,
    );
  }

  void _upsertStops(Iterable<Stop> stops) {
    for (final stop in stops) {
      _stopsById[stop.id] = stop;
    }
  }

  List<Stop> get _sortedStops => sortStopsByPublicName(_stopsById.values);

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}
