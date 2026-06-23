import '../vehicle_position.dart';

abstract interface class VehiclePositionRepository {
  Future<VehiclePosition> fetchVehiclePosition(String gtfsTripId);
}
