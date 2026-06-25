import '../../../../core/errors/app_exception.dart';
import '../../../../core/logging/golemio_debug_logger.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/gtfs_stops_query.dart';
import '../../domain/repositories/stops_repository.dart';
import '../../domain/stop.dart';
import '../../domain/stop_parent_aliases.dart';
import '../../domain/stop_visibility.dart';
import '../../domain/stops_page.dart';
import '../datasources/stops_remote_data_source.dart';
import '../models/stop_dto.dart';

typedef _ParsedStops = ({
  List<Stop> stops,
  ParserDiagnostics diagnostics,
  Map<String, String> parentStationNamesById,
});

class GolemioStopsRepository implements PaginatedStopsRepository {
  const GolemioStopsRepository(this._remoteDataSource);

  final StopsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Stop>> fetchStops() async {
    final page = await fetchStopsPage(
      const GtfsStopsQuery(limit: 1000, offset: 0),
    );

    if (page.stops.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return any valid public stops.',
      );
    }

    return page.stops;
  }

  @override
  Future<StopsPage> fetchStopsPage(GtfsStopsQuery query) async {
    final parsed = await _fetchParsedStops(query);
    final rawReturnedCount = parsed.diagnostics.rawCount;
    final limit = query.limit ?? rawReturnedCount;
    final offset = query.offset ?? 0;

    return StopsPage(
      stops: parsed.stops,
      limit: limit,
      offset: offset,
      rawReturnedCount: rawReturnedCount,
      hasMore: query.limit != null && rawReturnedCount == query.limit,
      parentStationNamesById: parsed.parentStationNamesById,
    );
  }

  Future<ParsedResult<Stop>> fetchStopsWithDiagnostics([
    GtfsStopsQuery query = const GtfsStopsQuery(),
  ]) async {
    final parsed = await _fetchParsedStops(query);

    return ParsedResult<Stop>(
      items: parsed.stops,
      diagnostics: parsed.diagnostics,
    );
  }

  Future<_ParsedStops> _fetchParsedStops(GtfsStopsQuery query) async {
    final response = await _remoteDataSource.fetchStops(StopsRequest(query));
    final parsed = StopDto.parseWithDiagnostics(response);
    final parsedStops = parsed.items.map((dto) => dto.toDomain()).toList();
    final parentNamesById = parentStationNamesById(parsedStops);
    final stops = attachParentStationAliases(
      sortedUserFacingStops(parsedStops),
      parentNamesById,
    );
    final diagnostics = parsed.diagnostics;
    final filteredCount = parsedStops.length - stops.length;

    logGolemioDebug(
      'Stops parsed raw=${diagnostics.rawCount} '
      'parsed=${diagnostics.parsedCount} skipped=${diagnostics.skippedCount} '
      'limit=${query.limit?.toString() ?? '-'} '
      'offset=${query.offset?.toString() ?? '-'} '
      'names=${query.names?.join('|') ?? '-'} '
      'public=${stops.length} filtered=$filteredCount '
      'sample=${_sampleStops(stops)} '
      'skipReasons=${_skipReasons(diagnostics.skipReasons)}',
    );

    return (
      stops: stops,
      diagnostics: diagnostics,
      parentStationNamesById: parentNamesById,
    );
  }
}

String _sampleStops(List<Stop> stops) {
  return stops
      .take(5)
      .map(
        (stop) =>
            '${stop.id}:${stop.name}'
            ':platform=${stop.platformCode ?? '-'}'
            ':zone=${stop.zoneId ?? '-'}'
            ':type=${stop.locationType?.toString() ?? '-'}'
            ':parent=${stop.parentStationId ?? '-'}'
            ':wheelchair=${stop.wheelchairBoarding?.toString() ?? '-'}'
            ':level=${stop.levelId ?? '-'}',
      )
      .join(' | ');
}

String _skipReasons(List<ParserSkipReason> skipReasons) {
  if (skipReasons.isEmpty) {
    return '-';
  }

  return skipReasons
      .map((reason) => '#${reason.index}:${reason.reason}')
      .join(' | ');
}
