import '../gtfs_stops_query.dart';
import '../stops_page.dart';
import 'get_stops_use_case.dart';

class LoadStopGroupsUseCase {
  const LoadStopGroupsUseCase(this._getStops);

  final GetStopsUseCase _getStops;

  Future<StopsPage> call({required int limit, required int offset}) {
    return _getStops.page(GtfsStopsQuery(limit: limit, offset: offset));
  }
}
