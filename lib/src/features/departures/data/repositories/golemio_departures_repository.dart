import '../../../../core/errors/app_exception.dart';
import '../../../../core/logging/golemio_debug_logger.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../../stops/domain/stop_group.dart';
import '../../domain/departure.dart';
import '../../domain/departure_aggregation.dart';
import '../../domain/repositories/departures_repository.dart';
import '../datasources/departures_remote_data_source.dart';
import '../models/departure_dto.dart';

class GolemioDeparturesRepository implements DeparturesRepository {
  const GolemioDeparturesRepository(this._remoteDataSource);

  final DeparturesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) async {
    final result = await fetchDeparturesForStopWithDiagnostics(stop);

    if (result.items.isEmpty) {
      if (result.diagnostics.rawCount == 0) {
        return const <Departure>[];
      }

      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return any valid departures.',
      );
    }

    return result.items;
  }

  Future<ParsedResult<Departure>> fetchDeparturesForStopWithDiagnostics(
    StopGroup stop,
  ) async {
    final seenStopIds = <String>{};
    final stopIds = stop.stopIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .where(seenStopIds.add)
        .toList(growable: false);

    if (stopIds.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The selected stop group does not contain any stop IDs.',
      );
    }

    final request = DepartureBoardRequest(stopIds: stopIds);

    logGolemioDebug(
      'Departures request stopGroup=${stop.id} stopName="${stop.name}" '
      'stopIds=${stopIds.join('|')} '
      '$departureBoardsStopFilterParameter=${request.stopIdsValue}',
    );

    final response = await _remoteDataSource.fetchDepartureBoard(request);
    final parsed = DepartureDto.parseWithDiagnostics(response);
    final parsedDepartures = parsed.items.map((dto) => dto.toDomain()).toList();
    final departures = aggregateDepartures(parsedDepartures);
    final diagnostics = parsed.diagnostics;

    logGolemioDebug(
      'Departures parsed stopGroup=${stop.id} raw=${diagnostics.rawCount} '
      'parsed=${diagnostics.parsedCount} skipped=${diagnostics.skippedCount} '
      'aggregated=${departures.length} '
      'sample=${_sampleDepartures(departures)} '
      'skipReasons=${_skipReasons(diagnostics.skipReasons)}',
    );

    return ParsedResult<Departure>(
      items: List<Departure>.unmodifiable(departures),
      diagnostics: diagnostics,
    );
  }
}

String _sampleDepartures(List<Departure> departures) {
  return departures
      .take(5)
      .map(
        (departure) =>
            '${departure.routeShortName}->${departure.headsign}'
            ':trip=${departure.gtfsTripId ?? '-'}'
            ':vehicle=${departure.vehicleId ?? '-'}',
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
