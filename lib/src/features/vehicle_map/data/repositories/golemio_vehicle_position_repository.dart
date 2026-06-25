import '../../../../core/errors/app_exception.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/repositories/vehicle_position_repository.dart';
import '../../domain/vehicle_id.dart';
import '../../domain/vehicle_position.dart';
import '../datasources/vehicle_positions_remote_data_source.dart';
import '../models/vehicle_position_dto.dart';

class GolemioVehiclePositionRepository implements VehiclePositionRepository {
  const GolemioVehiclePositionRepository(this._remoteDataSource);

  final VehiclePositionsRemoteDataSource _remoteDataSource;

  @override
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId) async {
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
    VehicleId vehicleId,
  ) async {
    final response = await _remoteDataSource.fetchVehiclePosition(
      VehiclePositionRequest(vehicleId: vehicleId),
    );
    final parsed = VehiclePositionDto.parseWithDiagnostics(
      response,
      fallbackVehicleId: vehicleId.value,
    );
    final positions = parsed.items.map((dto) => dto.toDomain()).toList();

    return ParsedResult<VehiclePosition>(
      items: List<VehiclePosition>.unmodifiable(positions),
      diagnostics: parsed.diagnostics,
    );
  }
}
