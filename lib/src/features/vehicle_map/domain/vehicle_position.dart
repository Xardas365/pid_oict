import 'package:meta/meta.dart';

@immutable
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehiclePosition &&
            vehicleId == other.vehicleId &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            bearing == other.bearing &&
            lastUpdated == other.lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(vehicleId, latitude, longitude, bearing, lastUpdated);
  }
}
