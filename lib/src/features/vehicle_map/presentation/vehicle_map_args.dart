import '../domain/vehicle_id.dart';

class VehicleMapArgs {
  const VehicleMapArgs({required this.vehicleId});

  final VehicleId vehicleId;

  static VehicleMapArgs? tryParseVehicleId(String? rawVehicleId) {
    final vehicleId = VehicleId.tryParse(rawVehicleId);
    if (vehicleId == null) {
      return null;
    }

    return VehicleMapArgs(vehicleId: vehicleId);
  }
}
