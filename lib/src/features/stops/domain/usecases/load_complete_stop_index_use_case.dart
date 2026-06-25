import '../gtfs_stops_query.dart';
import '../stop.dart';
import '../stop_parent_aliases.dart';
import '../stops_page.dart';
import 'get_stops_use_case.dart';

const gtfsCompleteStopsPageLimit = 10000;

class LoadCompleteStopIndexUseCase {
  const LoadCompleteStopIndexUseCase(this._getStops);

  final GetStopsUseCase _getStops;

  Future<StopsPage> call({
    int limit = gtfsCompleteStopsPageLimit,
    int offset = 0,
  }) async {
    final stopsById = <String, Stop>{};
    final parentNamesById = <String, String>{};
    var nextOffset = offset;
    var rawReturnedCount = 0;
    var hasMore = true;

    while (hasMore) {
      final page = await _getStops.page(
        GtfsStopsQuery(limit: limit, offset: nextOffset),
      );

      for (final stop in page.stops) {
        stopsById[stop.id] = stop;
      }
      parentNamesById.addAll(page.parentStationNamesById);

      rawReturnedCount += page.rawReturnedCount;

      if (!page.hasMore || page.rawReturnedCount <= 0) {
        hasMore = false;
        break;
      }

      nextOffset += page.rawReturnedCount;
    }

    return StopsPage(
      stops: attachParentStationAliases(stopsById.values, parentNamesById),
      limit: limit,
      offset: offset,
      rawReturnedCount: rawReturnedCount,
      hasMore: false,
      parentStationNamesById: Map<String, String>.unmodifiable(
        parentNamesById,
      ),
    );
  }
}
