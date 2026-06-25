import '../../domain/vehicle_id.dart';

sealed class VehicleMapEvent {
  const VehicleMapEvent();
}

class VehicleMapStarted extends VehicleMapEvent {
  const VehicleMapStarted(this.vehicleId);

  final VehicleId vehicleId;
}

class VehicleMapRetried extends VehicleMapEvent {
  const VehicleMapRetried();
}

class VehicleMapRefreshTicked extends VehicleMapEvent {
  const VehicleMapRefreshTicked();
}
