import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/golemio_api_client.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/repositories/vehicle_position_repository.dart';
import '../../domain/vehicle_position.dart';
import '../models/vehicle_position_dto.dart';

class GolemioVehiclePositionRepository implements VehiclePositionRepository {
  const GolemioVehiclePositionRepository(this._apiClient);

  final GolemioApiClient _apiClient;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String gtfsTripId) async {
    final result = await fetchVehiclePositionsWithDiagnostics(gtfsTripId);
    final position = result.items.isEmpty ? null : result.items.first;

    if (position == null) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return a valid vehicle position.',
      );
    }

    return position;
  }

  Future<ParsedResult<VehiclePosition>> fetchVehiclePositionsWithDiagnostics(
    String gtfsTripId,
  ) async {
    final trimmedGtfsTripId = gtfsTripId.trim();
    if (trimmedGtfsTripId.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'GTFS trip ID is required to load vehicle position.',
      );
    }

    final response = await _apiClient.getJson(
      '/v2/vehiclepositions/${Uri.encodeComponent(trimmedGtfsTripId)}',
      queryParameters: const {
        'includeNotTracking': 'true',
        'includePositions': 'true',
        'preferredTimezone': 'Europe_Prague',
      },
    );
    final parsed = VehiclePositionDto.parseWithDiagnostics(response);
    final positions = parsed.items.map((dto) => dto.toDomain()).toList();

    return ParsedResult<VehiclePosition>(
      items: List<VehiclePosition>.unmodifiable(positions),
      diagnostics: parsed.diagnostics,
    );
  }
}
