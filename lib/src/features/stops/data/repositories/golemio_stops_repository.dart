import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/golemio_api_client.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/repositories/stops_repository.dart';
import '../../domain/stop.dart';
import '../models/stop_dto.dart';

class GolemioStopsRepository implements StopsRepository {
  const GolemioStopsRepository(this._apiClient);

  final GolemioApiClient _apiClient;

  @override
  Future<List<Stop>> fetchStops() async {
    final result = await fetchStopsWithDiagnostics();

    if (result.items.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return any valid stops.',
      );
    }

    return result.items;
  }

  Future<ParsedResult<Stop>> fetchStopsWithDiagnostics() async {
    final response = await _apiClient.getJson('/v2/gtfs/stops');
    final parsed = StopDto.parseWithDiagnostics(response);
    final stops = parsed.items.map((dto) => dto.toDomain()).toList();

    return ParsedResult<Stop>(
      items: List<Stop>.unmodifiable(stops),
      diagnostics: parsed.diagnostics,
    );
  }
}
