import '../stop.dart';
import '../stops_page.dart';
import 'stop_search_index.dart';
import 'stop_search_query.dart';

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

  bool isRemoteSearchQuery(String query) {
    return StopSearchQuery.parse(query).normalizedInput.length >=
        minApiSearchLength;
  }

  bool shouldUseRemoteSupplement(String query, StopSearchIndex index) {
    final normalizedQuery = StopSearchQuery.parse(query).normalizedInput;
    return !index.isComplete &&
        normalizedQuery.length >= minApiSearchLength &&
        normalizedQuery != _lastRequestedSearch;
  }

  void resetLastRequestedSearch() {
    _lastRequestedSearch = '';
  }

  Future<StopsSearchResult?> search({
    required String query,
    required StopSearchIndex index,
  }) async {
    final searchQuery = StopSearchQuery.parse(query);
    final requestQuery = query.trim();

    if (!shouldUseRemoteSupplement(query, index)) {
      return null;
    }

    _lastRequestedSearch = searchQuery.normalizedInput;

    final page = await searchStops(query: requestQuery, limit: searchLimit);
    final searchStopsById = <String, Stop>{};
    for (final stop in page.stops) {
      searchStopsById[stop.id] = stop;
    }

    return StopsSearchResult.remote(
      normalizedQuery: searchQuery.normalizedInput,
      stops: _sortStopsByPublicName(searchStopsById.values),
    );
  }

  String normalizeQuery(String query) {
    return StopSearchQuery.parse(query).normalizedInput;
  }

  List<Stop> _sortStopsByPublicName(Iterable<Stop> stops) {
    final sortedStops = stops.toList(growable: false)
      ..sort((first, second) {
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
      });

    return List<Stop>.unmodifiable(sortedStops);
  }
}

class StopsSearchResult {
  const StopsSearchResult._({
    required this.normalizedQuery,
    required this.stops,
  });

  factory StopsSearchResult.remote({
    required String normalizedQuery,
    required List<Stop> stops,
  }) {
    return StopsSearchResult._(
      normalizedQuery: normalizedQuery,
      stops: List<Stop>.unmodifiable(stops),
    );
  }

  final String normalizedQuery;
  final List<Stop> stops;
}
