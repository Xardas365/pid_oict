sealed class VehicleMapEvent {
  const VehicleMapEvent();
}

class VehicleMapStarted extends VehicleMapEvent {
  const VehicleMapStarted(this.gtfsTripId);

  final String gtfsTripId;
}

class VehicleMapRetried extends VehicleMapEvent {
  const VehicleMapRetried();
}

class VehicleMapRefreshTicked extends VehicleMapEvent {
  const VehicleMapRefreshTicked();
}
