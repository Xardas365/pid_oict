import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
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
    final vehicleId = readString(json, _vehicleIdPaths);
    final coordinates = readGeoJsonPoint(json);

    if (vehicleId == null || coordinates == null) {
      return null;
    }

    return VehiclePositionDto(
      vehicleId: vehicleId,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      bearing: readDouble(json, _bearingPaths),
      lastUpdated: readDateTime(json, _lastUpdatedPaths),
    );
  }

  static ParsedResult<VehiclePositionDto> parseWithDiagnostics(
    Object? response,
  ) {
    return parseJsonRecordsWithDiagnostics<VehiclePositionDto>(
      response: response,
      parse: VehiclePositionDto.fromJson,
      skipReason: invalidReason,
    );
  }

  static String invalidReason(JsonMap json) {
    if (readString(json, _vehicleIdPaths) == null) {
      return 'missing vehicle id';
    }

    if (_hasAnyCoordinateValue(json)) {
      return 'invalid coordinate shape';
    }

    return 'missing coordinates';
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

const _vehicleIdPaths = [
  ['vehicle_id'],
  ['vehicleId'],
  ['id'],
  ['properties', 'vehicle_id'],
  ['properties', 'vehicleId'],
  ['properties', 'id'],
  ['vehicle', 'id'],
  ['properties', 'vehicle', 'id'],
];

const _bearingPaths = [
  ['bearing'],
  ['bearing_deg'],
  ['properties', 'bearing'],
  ['properties', 'bearing_deg'],
  ['position', 'bearing'],
  ['properties', 'position', 'bearing'],
];

const _lastUpdatedPaths = [
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
];

bool _hasAnyCoordinateValue(JsonMap json) {
  return readJsonValue(json, [
        ['geometry', 'coordinates'],
        ['properties', 'geometry', 'coordinates'],
        ['latitude'],
        ['lat'],
        ['properties', 'latitude'],
        ['properties', 'lat'],
        ['position', 'latitude'],
        ['position', 'lat'],
        ['properties', 'position', 'latitude'],
        ['properties', 'position', 'lat'],
        ['longitude'],
        ['lon'],
        ['lng'],
        ['properties', 'longitude'],
        ['properties', 'lon'],
        ['properties', 'lng'],
        ['position', 'longitude'],
        ['position', 'lon'],
        ['position', 'lng'],
        ['properties', 'position', 'longitude'],
        ['properties', 'position', 'lon'],
        ['properties', 'position', 'lng'],
      ]) !=
      null;
}
