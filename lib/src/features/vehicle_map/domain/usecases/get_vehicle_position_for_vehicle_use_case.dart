import '../repositories/vehicle_position_repository.dart';
import '../vehicle_id.dart';
import '../vehicle_position.dart';

class GetVehiclePositionForVehicleUseCase {
  const GetVehiclePositionForVehicleUseCase(this._repository);

  final VehiclePositionRepository _repository;

  Future<VehiclePosition> call(VehicleId vehicleId) {
    return _repository.fetchVehiclePosition(vehicleId);
  }
}
