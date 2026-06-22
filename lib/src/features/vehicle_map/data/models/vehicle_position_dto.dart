import '../../../../shared/utils/json_parsing.dart';
import '../../domain/vehicle_position.dart';

class VehiclePositionDto {
  const VehiclePositionDto({
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

  static VehiclePositionDto? fromJson(JsonMap json) {
    final vehicleId = readString(json, [
      ['vehicle_id'],
      ['vehicleId'],
      ['id'],
      ['properties', 'vehicle_id'],
      ['properties', 'vehicleId'],
      ['properties', 'id'],
      ['vehicle', 'id'],
      ['properties', 'vehicle', 'id'],
    ]);
    final coordinates = readGeoJsonPoint(json);

    if (vehicleId == null || coordinates == null) {
      return null;
    }

    return VehiclePositionDto(
      vehicleId: vehicleId,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      bearing: readDouble(json, [
        ['bearing'],
        ['bearing_deg'],
        ['properties', 'bearing'],
        ['properties', 'bearing_deg'],
        ['position', 'bearing'],
        ['properties', 'position', 'bearing'],
      ]),
      lastUpdated: readDateTime(json, [
        ['last_updated'],
        ['lastUpdated'],
        ['updated_at'],
        ['updatedAt'],
        ['timestamp'],
        ['properties', 'last_updated'],
        ['properties', 'lastUpdated'],
        ['properties', 'updated_at'],
        ['properties', 'updatedAt'],
        ['properties', 'timestamp'],
      ]),
    );
  }

  VehiclePosition toDomain() {
    return VehiclePosition(
      vehicleId: vehicleId,
      latitude: latitude,
      longitude: longitude,
      bearing: bearing,
      lastUpdated: lastUpdated,
    );
  }
}
