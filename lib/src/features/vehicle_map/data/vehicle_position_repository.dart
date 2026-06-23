import '../../../core/errors/app_exception.dart';
import '../../../core/network/golemio_api_client.dart';
import '../../../shared/utils/json_parsing.dart';
import '../domain/vehicle_position.dart';
import 'models/vehicle_position_dto.dart';

class VehiclePositionRepository {
  const VehiclePositionRepository(this._apiClient);

  final GolemioApiClient _apiClient;

  Future<VehiclePosition> fetchVehiclePosition(String gtfsTripId) async {
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
    VehiclePosition? position;
    for (final record in readJsonRecords(response)) {
      final dto = VehiclePositionDto.fromJson(record);
      if (dto != null) {
        position = dto.toDomain();
        break;
      }
    }

    if (position == null) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'The Golemio API did not return a valid vehicle position.',
      );
    }

    return position;
  }
}
