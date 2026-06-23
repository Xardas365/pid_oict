import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/golemio_api_client.dart';
import '../../../../shared/utils/json_parsing.dart';
import '../../domain/repositories/stops_repository.dart';
import '../../domain/stop.dart';
import '../models/stop_dto.dart';

class GolemioStopsRepository implements StopsRepository {
  const GolemioStopsRepository(this._apiClient);

  final GolemioApiClient _apiClient;

  @override
  Future<List<Stop>> fetchStops() async {
    final response = await _apiClient.getJson('/v2/gtfs/stops');
    final stops = readJsonRecords(response)
        .map(StopDto.fromJson)
        .whereType<StopDto>()
        .map((dto) => dto.toDomain())
        .toList();

    if (stops.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return any valid stops.',
      );
    }

    return stops;
  }
}
