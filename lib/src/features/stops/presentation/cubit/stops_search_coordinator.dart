import '../../domain/stop.dart';
import '../../domain/stop_group.dart';
import '../../domain/stops_page.dart';
import '../stop_filter.dart';
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

  var _lastRequestedSearch = '';

  bool shouldUseApiSearch(String query) {
    return normalizeQuery(query).length >= minApiSearchLength;
  }

  void resetLastRequestedSearch() {
    _lastRequestedSearch = '';
  }

  Future<StopsSearchResult?> search({
    required String query,
    required List<Stop> loadedStops,
  }) async {
    final normalizedQuery = normalizeQuery(query);
    if (!shouldUseApiSearch(normalizedQuery) ||
        normalizedQuery == _lastRequestedSearch) {
      return null;
    }

    _lastRequestedSearch = normalizedQuery;

    final page = await searchStops(query: normalizedQuery, limit: searchLimit);
    final searchStopsById = <String, Stop>{};
    for (final stop in page.stops) {
      searchStopsById[stop.id] = stop;
    }

    final remoteStops = sortStopsByPublicName(searchStopsById.values);
    final localFallbackGroups = filterStopGroupsByName(
      groupStops(loadedStops),
      query,
    );

    if (remoteStops.isEmpty && localFallbackGroups.isNotEmpty) {
      return StopsSearchResult.localFallback(normalizedQuery: normalizedQuery);
    }

    return StopsSearchResult.remote(
      normalizedQuery: normalizedQuery,
      stops: remoteStops,
    );
  }

  String normalizeQuery(String query) {
    return query.trim();
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
