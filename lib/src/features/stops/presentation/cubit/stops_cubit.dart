import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../stop_filter.dart';
import 'stops_state.dart';

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
       super(const StopsState.loading());

  final LoadStopGroupsUseCase _loadStopGroups;
  final RefreshStopGroupsUseCase _refreshStopGroups;
  final SearchStopGroupsUseCase _searchStopGroups;
  final LoadCachedStopsUseCase? loadCachedStops;
  final SaveStopsCacheUseCase? saveStopsCache;
  final LoadSavedStopGroupsUseCase? loadSavedStopGroups;
  final ToggleFavoriteStopUseCase? toggleFavoriteStop;
  final RecordRecentStopUseCase? recordRecentStopUseCase;
  final DateTime Function() _now;
  final int pageSize;
  final int searchLimit;
  final Duration searchDebounceDuration;
  final _stopsById = <String, Stop>{};
  var _favoriteGroupIds = const <String>[];
  var _recentGroupIds = const <String>[];

  Timer? _searchDebounceTimer;
  var _lastRequestedSearch = '';
  var _initialRefreshInProgress = false;

  Future<void> loadStops() async {
    _searchDebounceTimer?.cancel();
    _stopsById.clear();
    _lastRequestedSearch = '';

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
      StopsState(
        status: StopsStatus.loading,
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
        StopsState(
          status: StopsStatus.error,
          error: error,
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
          cacheRefreshError: error,
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
        _shouldUseApiSearch(current.searchQuery)) {
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
      emit(current.copyWith(isLoadingMore: false, error: error));
    }
  }

  void searchChanged(String query) {
    final current = state;
    if (current.status == StopsStatus.loading ||
        current.status == StopsStatus.error) {
      return;
    }

    _searchDebounceTimer?.cancel();

    if (!_shouldUseApiSearch(query)) {
      _lastRequestedSearch = '';
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
    final normalizedQuery = query.trim();
    if (!_shouldUseApiSearch(normalizedQuery) ||
        normalizedQuery == _lastRequestedSearch) {
      return;
    }

    _lastRequestedSearch = normalizedQuery;

    try {
      final page = await _searchStopGroups(
        query: normalizedQuery,
        limit: searchLimit,
      );
      final stopsById = <String, Stop>{};
      for (final stop in page.stops) {
        stopsById[stop.id] = stop;
      }
      final searchStops = _sortStops(stopsById.values);
      final shouldUseLocalFallback =
          searchStops.isEmpty &&
          filterStopGroupsByName(groupStops(_sortedStops), query).isNotEmpty;

      if (state.searchQuery.trim() != normalizedQuery) {
        return;
      }

      if (shouldUseLocalFallback) {
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
          searchStops,
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
      if (state.searchQuery.trim() != normalizedQuery) {
        return;
      }

      emit(
        StopsState(
          status: StopsStatus.error,
          allStops: _sortedStops,
          searchQuery: query,
          error: error,
          allGroups: groupStops(_sortedStops),
          hasMore: state.hasMore,
          nextOffset: state.nextOffset,
          isFromCache: state.isFromCache,
          isCacheStale: state.isCacheStale,
          cacheRefreshError: state.cacheRefreshError,
          favoriteGroupIds: _favoriteGroupIds,
          recentGroupIds: _recentGroupIds,
          favoriteGroups: _resolveGroups(
            groupStops(_sortedStops),
            _favoriteGroupIds,
          ),
          recentGroups: _resolveGroups(
            groupStops(_sortedStops),
            _recentGroupIds,
          ),
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
    Object? cacheRefreshError,
    bool clearCacheRefreshError = false,
  }) {
    final allStops = List<Stop>.unmodifiable(stops);
    final allGroups = groupStops(allStops);
    final filteredGroups = useProvidedStopsDirectly
        ? allGroups
        : filterStopGroupsByName(allGroups, searchQuery);
    final filteredStops = _representativeStops(filteredGroups);
    final status = filteredGroups.isEmpty
        ? StopsStatus.empty
        : StopsStatus.loaded;

    return StopsState(
      status: status,
      allStops: allStops,
      filteredStops: filteredStops,
      allGroups: allGroups,
      filteredGroups: filteredGroups,
      searchQuery: searchQuery,
      hasMore: hasMore,
      nextOffset: nextOffset,
      isLoadingMore: isLoadingMore,
      isSearching: isSearching,
      isFromCache: isFromCache,
      isCacheStale: isCacheStale,
      cacheRefreshError: clearCacheRefreshError ? null : cacheRefreshError,
      favoriteGroupIds: _favoriteGroupIds,
      recentGroupIds: _recentGroupIds,
      favoriteGroups: _resolveGroups(allGroups, _favoriteGroupIds),
      recentGroups: _resolveGroups(allGroups, _recentGroupIds),
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
      state.copyWith(
        favoriteGroupIds: _favoriteGroupIds,
        recentGroupIds: _recentGroupIds,
        favoriteGroups: _resolveGroups(state.allGroups, _favoriteGroupIds),
        recentGroups: _resolveGroups(state.allGroups, _recentGroupIds),
      ),
    );
  }

  List<StopGroup> _resolveGroups(
    List<StopGroup> groups,
    List<String> groupIds,
  ) {
    final groupsById = {for (final group in groups) group.id: group};
    final resolvedGroups = <StopGroup>[];

    for (final groupId in groupIds) {
      final group = groupsById[groupId];
      if (group != null) {
        resolvedGroups.add(group);
      }
    }

    return List<StopGroup>.unmodifiable(resolvedGroups);
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

  List<Stop> _representativeStops(List<StopGroup> groups) {
    return List<Stop>.unmodifiable(
      groups.map((group) => group.representativeStop),
    );
  }

  bool _shouldUseApiSearch(String query) {
    return query.trim().length >= minGtfsStopsApiSearchLength;
  }

  void _upsertStops(Iterable<Stop> stops) {
    for (final stop in stops) {
      _stopsById[stop.id] = stop;
    }
  }

  List<Stop> get _sortedStops => _sortStops(_stopsById.values);

  List<Stop> _sortStops(Iterable<Stop> stops) {
    final sortedStops = stops.toList(growable: false)
      ..sort(_compareStopsByPublicName);

    return List<Stop>.unmodifiable(sortedStops);
  }

  int _compareStopsByPublicName(Stop first, Stop second) {
    final nameComparison = first.name.toLowerCase().compareTo(
      second.name.toLowerCase(),
    );
    if (nameComparison != 0) {
      return nameComparison;
    }

    final platformComparison = (first.platformCode ?? '').compareTo(
      second.platformCode ?? '',
    );
    if (platformComparison != 0) {
      return platformComparison;
    }

    return first.id.compareTo(second.id);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}
