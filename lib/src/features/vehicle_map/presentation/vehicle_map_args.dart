import 'package:meta/meta.dart';

import '../domain/vehicle_id.dart';

@immutable
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleMapArgs && vehicleId == other.vehicleId;
  }

  @override
  int get hashCode => vehicleId.hashCode;
}
