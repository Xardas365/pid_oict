import '../gtfs_stops_query.dart';
import '../stop.dart';
import '../stops_page.dart';

abstract interface class StopsRepository {
  Future<List<Stop>> fetchStops();
}

abstract interface class PaginatedStopsRepository implements StopsRepository {
  Future<StopsPage> fetchStopsPage(GtfsStopsQuery query);
}
