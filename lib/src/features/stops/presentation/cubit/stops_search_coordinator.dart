import '../../domain/search/stop_search_index.dart';
import '../../domain/search/stop_search_matcher.dart';
import '../../domain/search/stop_search_query.dart';
import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
import '../../domain/stops_page.dart';
import 'stops_sorting.dart';

typedef StopsApiSearch =
    Future<StopsPage> Function({
      required String query,
      required int limit,
    });

class StopsSearchCoordinator {
  StopsSearchCoordinator({
    required this.searchStops,
    required this.searchLimit,
    required this.minApiSearchLength,
  });

  final StopsApiSearch searchStops;
  final int searchLimit;
  final int minApiSearchLength;
  final StopSearchMatcher _searchMatcher = const StopSearchMatcher();

  var _lastRequestedSearch = '';

  bool shouldUseApiSearch(String query) {
    return StopSearchQuery.parse(query).normalizedInput.length >=
        minApiSearchLength;
  }

  void resetLastRequestedSearch() {
    _lastRequestedSearch = '';
  }

  Future<StopsSearchResult?> search({
    required String query,
    required List<Stop> loadedStops,
  }) async {
    final searchQuery = StopSearchQuery.parse(query);
    final requestQuery = query.trim();

    if (!shouldUseApiSearch(query) ||
        searchQuery.normalizedInput == _lastRequestedSearch) {
      return null;
    }

    _lastRequestedSearch = searchQuery.normalizedInput;

    final page = await searchStops(query: requestQuery, limit: searchLimit);
    final searchStopsById = <String, Stop>{};
    for (final stop in page.stops) {
      searchStopsById[stop.id] = stop;
    }

    final remoteStops = sortStopsByPublicName(searchStopsById.values);
    final localFallbackGroups = _searchMatcher.matchGroups(
      StopSearchIndex.fromGroups(groupStops(loadedStops)),
      searchQuery,
    );

    if (remoteStops.isEmpty && localFallbackGroups.isNotEmpty) {
      return StopsSearchResult.localFallback(
        normalizedQuery: searchQuery.normalizedInput,
      );
    }

    return StopsSearchResult.remote(
      normalizedQuery: searchQuery.normalizedInput,
      stops: remoteStops,
    );
  }

  String normalizeQuery(String query) {
    return StopSearchQuery.parse(query).normalizedInput;
  }
}

class StopsSearchResult {
  const StopsSearchResult._({
    required this.normalizedQuery,
    required this.stops,
    required this.useLocalFallback,
  });

  factory StopsSearchResult.remote({
    required String normalizedQuery,
    required List<Stop> stops,
  }) {
    return StopsSearchResult._(
      normalizedQuery: normalizedQuery,
      stops: List<Stop>.unmodifiable(stops),
      useLocalFallback: false,
    );
  }

  factory StopsSearchResult.localFallback({required String normalizedQuery}) {
    return StopsSearchResult._(
      normalizedQuery: normalizedQuery,
      stops: const <Stop>[],
      useLocalFallback: true,
    );
  }

  final String normalizedQuery;
  final List<Stop> stops;
  final bool useLocalFallback;
}
