import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/saved_stops_data_source.dart';
import '../../data/datasources/stops_cache_data_source.dart';
import '../../data/models/cached_stops.dart';
import '../../data/models/saved_stops.dart';
import '../../domain/gtfs_stops_query.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
import '../../domain/stop_visibility.dart';
import '../../domain/usecases/get_stops_use_case.dart';
import '../stop_filter.dart';
import 'stops_state.dart';

const gtfsStopsPageSize = 500;
const gtfsStopsSearchLimit = 100;
const minGtfsStopsApiSearchLength = 3;
const gtfsStopsSearchDebounceDuration = Duration(milliseconds: 350);

class StopsCubit extends Cubit<StopsState> {
  StopsCubit(
    this._getStops, {
    this.pageSize = gtfsStopsPageSize,
    this.searchLimit = gtfsStopsSearchLimit,
    this.searchDebounceDuration = gtfsStopsSearchDebounceDuration,
    this.cacheDataSource,
    this.savedStopsDataSource,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const StopsState.loading());

  final GetStopsUseCase _getStops;
  final StopsCacheDataSource? cacheDataSource;
  final SavedStopsDataSource? savedStopsDataSource;
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
      final page = await _getStops.page(
        GtfsStopsQuery(limit: pageSize, offset: 0),
      );
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
    } catch (error) {
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
      final page = await _getStops.page(
        GtfsStopsQuery(limit: pageSize, offset: 0),
      );
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
          isFromCache: false,
          isCacheStale: false,
        ),
      );
      await _writeCacheFromCurrentStops(
        hasMore: page.hasMore,
        nextOffset: nextOffset,
      );
    } catch (error) {
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
    final favorites = FavoriteStops(
      updatedAt: updatedAt,
      favoriteGroupIds: _favoriteGroupIds,
    );
    final updatedFavorites = state.isFavorite(group)
        ? favorites.remove(group.id, updatedAt: updatedAt)
        : favorites.add(group.id, updatedAt: updatedAt);

    _favoriteGroupIds = updatedFavorites.favoriteGroupIds;
    _emitStateWithSavedStops();
    await _writeFavorites(updatedFavorites);
  }

  Future<void> recordRecentStop(StopGroup group) async {
    final updatedAt = _now().toUtc();
    final updatedRecent = RecentStops(
      updatedAt: updatedAt,
      recentGroupIds: _recentGroupIds,
    ).add(group.id, updatedAt: updatedAt);

    _recentGroupIds = updatedRecent.recentGroupIds;
    _emitStateWithSavedStops();
    await _writeRecent(updatedRecent);
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
      final page = await _getStops.page(
        GtfsStopsQuery(limit: pageSize, offset: current.nextOffset),
      );
      _upsertStops(page.stops);

      emit(
        _stateFromStops(
          _sortedStops,
          searchQuery: current.searchQuery,
          hasMore: page.hasMore,
          nextOffset: current.nextOffset + page.rawReturnedCount,
          isFromCache: false,
          isCacheStale: false,
          clearCacheRefreshError: true,
        ),
      );
      await _writeCacheFromCurrentStops(
        hasMore: page.hasMore,
        nextOffset: current.nextOffset + page.rawReturnedCount,
      );
    } catch (error) {
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
      final page = await _getStops.page(
        GtfsStopsQuery(limit: searchLimit, offset: 0, names: [normalizedQuery]),
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
            isSearching: false,
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
          isSearching: false,
          useProvidedStopsDirectly: true,
          isFromCache: state.isFromCache,
          isCacheStale: state.isCacheStale,
          cacheRefreshError: state.cacheRefreshError,
        ),
      );
    } catch (error) {
      if (state.searchQuery.trim() != normalizedQuery) {
        return;
      }

      emit(
        StopsState(
          status: StopsStatus.error,
          allStops: _sortedStops,
          filteredStops: const <Stop>[],
          searchQuery: query,
          error: error,
          allGroups: groupStops(_sortedStops),
          filteredGroups: const <StopGroup>[],
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
    final dataSource = savedStopsDataSource;
    if (dataSource == null) {
      _favoriteGroupIds = const <String>[];
      _recentGroupIds = const <String>[];
      return;
    }

    try {
      _favoriteGroupIds = (await dataSource.readFavorites()).favoriteGroupIds;
    } catch (_) {
      _favoriteGroupIds = const <String>[];
    }

    try {
      _recentGroupIds = (await dataSource.readRecent()).recentGroupIds;
    } catch (_) {
      _recentGroupIds = const <String>[];
    }
  }

  Future<void> _writeFavorites(FavoriteStops favorites) async {
    final dataSource = savedStopsDataSource;
    if (dataSource == null) {
      return;
    }

    try {
      await dataSource.writeFavorites(favorites);
    } catch (_) {
      // Saved-stop persistence must not block the main stops flow.
    }
  }

  Future<void> _writeRecent(RecentStops recent) async {
    final dataSource = savedStopsDataSource;
    if (dataSource == null) {
      return;
    }

    try {
      await dataSource.writeRecent(recent);
    } catch (_) {
      // Saved-stop persistence must not block departure navigation.
    }
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

  Future<CachedStops?> _readCache() async {
    final dataSource = cacheDataSource;
    if (dataSource == null) {
      return null;
    }

    try {
      return await dataSource.read();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCacheFromCurrentStops({
    required bool hasMore,
    required int nextOffset,
  }) async {
    final dataSource = cacheDataSource;
    if (dataSource == null) {
      return;
    }

    final publicStops = sortedUserFacingStops(_stopsById.values);
    if (publicStops.isEmpty) {
      return;
    }

    try {
      await dataSource.write(
        CachedStops(
          cachedAt: _now().toUtc(),
          stops: publicStops,
          hasMore: hasMore,
          nextOffset: nextOffset,
        ),
      );
    } catch (_) {
      // Cache failures must not block live stop loading.
    }
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
