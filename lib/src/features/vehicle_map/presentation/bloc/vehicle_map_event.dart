sealed class VehicleMapEvent {
  const VehicleMapEvent();
}

class VehicleMapStarted extends VehicleMapEvent {
  const VehicleMapStarted(this.vehicleId);

  final String vehicleId;
}

class VehicleMapRetried extends VehicleMapEvent {
  const VehicleMapRetried();
}

class VehicleMapRefreshTicked extends VehicleMapEvent {
  const VehicleMapRefreshTicked();
}
