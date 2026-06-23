import '../repositories/vehicle_position_repository.dart';
import '../vehicle_position.dart';

class GetVehiclePositionForTripUseCase {
  const GetVehiclePositionForTripUseCase(this._repository);

  final VehiclePositionRepository _repository;

  Future<VehiclePosition> call(String gtfsTripId) {
    return _repository.fetchVehiclePosition(gtfsTripId);
  }
}
