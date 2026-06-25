import '../vehicle_id.dart';
import '../vehicle_position.dart';

abstract interface class VehiclePositionRepository {
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId);
}
