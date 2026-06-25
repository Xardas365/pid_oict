import '../../../../core/errors/app_exception.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/repositories/vehicle_position_repository.dart';
import '../../domain/vehicle_position.dart';
import '../datasources/vehicle_positions_remote_data_source.dart';
import '../models/vehicle_position_dto.dart';

class GolemioVehiclePositionRepository implements VehiclePositionRepository {
  const GolemioVehiclePositionRepository(this._remoteDataSource);

  final VehiclePositionsRemoteDataSource _remoteDataSource;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String vehicleId) async {
    final result = await fetchVehiclePositionsWithDiagnostics(vehicleId);
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
    String vehicleId,
  ) async {
    final trimmedVehicleId = vehicleId.trim();
    if (trimmedVehicleId.isEmpty) {
      throw const AppException(
        type: AppExceptionType.invalidData,
        message: 'Vehicle ID is required to load vehicle position.',
      );
    }

    final response = await _remoteDataSource.fetchVehiclePosition(
      VehiclePositionRequest(vehicleId: trimmedVehicleId),
    );
    final parsed = VehiclePositionDto.parseWithDiagnostics(
      response,
      fallbackVehicleId: trimmedVehicleId,
    );
    final positions = parsed.items.map((dto) => dto.toDomain()).toList();

    return ParsedResult<VehiclePosition>(
      items: List<VehiclePosition>.unmodifiable(positions),
      diagnostics: parsed.diagnostics,
    );
  }
}
