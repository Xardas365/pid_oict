import '../../../../core/errors/app_exception.dart';
import '../../../../core/logging/golemio_debug_logger.dart';
import '../../../../core/network/golemio_api_client.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/gtfs_stops_query.dart';
import '../../domain/repositories/stops_repository.dart';
import '../../domain/stop.dart';
import '../../domain/stop_visibility.dart';
import '../../domain/stops_page.dart';
import '../gtfs_stops_query_parameters.dart';
import '../models/stop_dto.dart';

class GolemioStopsRepository implements PaginatedStopsRepository {
  const GolemioStopsRepository(this._apiClient);

  final GolemioApiClient _apiClient;

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
    final result = await fetchStopsWithDiagnostics(query);
    final rawReturnedCount = result.diagnostics.rawCount;
    final limit = query.limit ?? rawReturnedCount;
    final offset = query.offset ?? 0;

    return StopsPage(
      stops: result.items,
      limit: limit,
      offset: offset,
      rawReturnedCount: rawReturnedCount,
      hasMore: query.limit != null && rawReturnedCount == query.limit,
    );
  }

  Future<ParsedResult<Stop>> fetchStopsWithDiagnostics([
    GtfsStopsQuery query = const GtfsStopsQuery(),
  ]) async {
    final response = await _apiClient.getJson(gtfsStopsPathWithQuery(query));
    final parsed = StopDto.parseWithDiagnostics(response);
    final parsedStops = parsed.items.map((dto) => dto.toDomain()).toList();
    final stops = sortedUserFacingStops(parsedStops);
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

    return ParsedResult<Stop>(items: stops, diagnostics: diagnostics);
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
