import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/golemio_api_client.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../../stops/domain/stop.dart';
import '../../domain/departure.dart';
import '../../domain/repositories/departures_repository.dart';
import '../models/departure_dto.dart';

// Direct OpenAPI documentation was not available during implementation.
// Keep the departure board stop filter isolated here for live verification.
const departureBoardsStopFilterParameter = 'ids[]';

class GolemioDeparturesRepository implements DeparturesRepository {
  const GolemioDeparturesRepository(this._apiClient);

  final GolemioApiClient _apiClient;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) async {
    final result = await fetchDeparturesForStopWithDiagnostics(stop);

    if (result.items.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return any valid departures.',
      );
    }

    return result.items;
  }

  Future<ParsedResult<Departure>> fetchDeparturesForStopWithDiagnostics(
    Stop stop,
  ) async {
    final response = await _apiClient.getJson(
      '/v2/public/departureboards',
      queryParameters: {departureBoardsStopFilterParameter: stop.id},
    );
    final parsed = DepartureDto.parseWithDiagnostics(response);
    final departures = parsed.items.map((dto) => dto.toDomain()).toList();

    return ParsedResult<Departure>(
      items: List<Departure>.unmodifiable(departures),
      diagnostics: parsed.diagnostics,
    );
  }
}
