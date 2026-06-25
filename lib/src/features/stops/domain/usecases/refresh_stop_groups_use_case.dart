import '../gtfs_stops_query.dart';
import '../stops_page.dart';
import 'get_stops_use_case.dart';

class RefreshStopGroupsUseCase {
  const RefreshStopGroupsUseCase(this._getStops);

  final GetStopsUseCase _getStops;

  Future<StopsPage> call({required int limit}) {
    return _getStops.page(GtfsStopsQuery(limit: limit, offset: 0));
  }
}
