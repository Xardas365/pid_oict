import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/gtfs_stops_query.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
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
  }) : super(const StopsState.loading());

  final GetStopsUseCase _getStops;
  final int pageSize;
  final int searchLimit;
  final Duration searchDebounceDuration;
  final _stopsById = <String, Stop>{};

  Timer? _searchDebounceTimer;
  var _lastRequestedSearch = '';

  Future<void> loadStops() async {
    _searchDebounceTimer?.cancel();
    _stopsById.clear();
    _lastRequestedSearch = '';
    emit(const StopsState.loading());

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
    } catch (error) {
      emit(StopsState(status: StopsStatus.error, error: error));
    }
  }

  Future<void> retry() {
    return loadStops();
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
        ),
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

      if (state.searchQuery.trim() != normalizedQuery) {
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
