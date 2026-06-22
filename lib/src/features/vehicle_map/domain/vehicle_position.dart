class VehiclePosition {
  const VehiclePosition({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.lastUpdated,
  });

  final String vehicleId;
  final double latitude;
  final double longitude;
  final double? bearing;
  final DateTime? lastUpdated;
}
