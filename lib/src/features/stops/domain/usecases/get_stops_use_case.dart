import '../gtfs_stops_query.dart';
import '../repositories/stops_repository.dart';
import '../stop.dart';
import '../stops_page.dart';

class GetStopsUseCase {
  const GetStopsUseCase(this._repository);

  final StopsRepository _repository;

  Future<List<Stop>> call() {
    return _repository.fetchStops();
  }

  Future<StopsPage> page(GtfsStopsQuery query) {
    final repository = _repository;
    if (repository is PaginatedStopsRepository) {
      return repository.fetchStopsPage(query);
    }

    return _fallbackPage(query);
  }

  Future<StopsPage> _fallbackPage(GtfsStopsQuery query) async {
    final stops = await _repository.fetchStops();
    final queriedStops = _filterFallbackStops(stops, query);
    final limit = query.limit ?? queriedStops.length;
    final offset = query.offset ?? 0;

    return StopsPage(
      stops: List<Stop>.unmodifiable(queriedStops),
      limit: limit,
      offset: offset,
      rawReturnedCount: queriedStops.length,
      hasMore: false,
    );
  }

  List<Stop> _filterFallbackStops(List<Stop> stops, GtfsStopsQuery query) {
    final names = query.names
        ?.map((name) => name.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names == null || names.isEmpty) {
      return stops;
    }

    return stops
        .where(
          (stop) => names.any((name) => stop.name.toLowerCase().contains(name)),
        )
        .toList(growable: false);
  }
}
