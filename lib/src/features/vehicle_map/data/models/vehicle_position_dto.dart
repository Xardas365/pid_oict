import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/vehicle_position.dart';

class VehiclePositionDto {
  const VehiclePositionDto({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.gtfsTripId,
    this.routeShortName,
    this.routeType,
    this.headsign,
    this.bearing,
    this.delaySeconds,
    this.statePosition,
    this.lastStopSequence,
    this.shapeDistTraveled,
    this.routePoints = const <VehicleRoutePoint>[],
    this.stopTimes = const <VehicleRouteStop>[],
    this.vehicleDescriptor,
    this.lastUpdated,
  });

  final String vehicleId;
  final double latitude;
  final double longitude;
  final String? gtfsTripId;
  final String? routeShortName;
  final String? routeType;
  final String? headsign;
  final double? bearing;
  final int? delaySeconds;
  final String? statePosition;
  final int? lastStopSequence;
  final double? shapeDistTraveled;
  final List<VehicleRoutePoint> routePoints;
  final List<VehicleRouteStop> stopTimes;
  final VehicleDescriptor? vehicleDescriptor;
  final DateTime? lastUpdated;

  static VehiclePositionDto? fromJson(
    JsonMap json, {
    String? fallbackVehicleId,
  }) {
    final vehicleId = readString(json, _vehicleIdPaths) ?? fallbackVehicleId;
    final coordinates = readGeoJsonPoint(json);

    if (vehicleId == null || coordinates == null) {
      return null;
    }

    return VehiclePositionDto(
      vehicleId: vehicleId,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      gtfsTripId: readString(json, _gtfsTripIdPaths),
      routeShortName: readString(json, _routeShortNamePaths),
      routeType: readString(json, _routeTypePaths),
      headsign: readString(json, _headsignPaths),
      bearing: readDouble(json, _bearingPaths),
      delaySeconds: readInt(json, _delayPaths),
      statePosition: readString(json, _statePositionPaths),
      lastStopSequence: readInt(json, _lastStopSequencePaths),
      shapeDistTraveled: readDouble(json, _shapeDistTraveledPaths),
      routePoints: _parseRoutePoints(json),
      stopTimes: _parseRouteStops(json),
      vehicleDescriptor: _parseVehicleDescriptor(json),
      lastUpdated: readDateTime(json, _lastUpdatedPaths),
    );
  }

  static ParsedResult<VehiclePositionDto> parseWithDiagnostics(
    Object? response, {
    String? fallbackVehicleId,
  }) {
    return parseJsonRecordsWithDiagnostics<VehiclePositionDto>(
      response: response,
      parse: (json) => VehiclePositionDto.fromJson(
        json,
        fallbackVehicleId: fallbackVehicleId,
      ),
      skipReason: (json) =>
          invalidReason(json, fallbackVehicleId: fallbackVehicleId),
    );
  }

  static String invalidReason(JsonMap json, {String? fallbackVehicleId}) {
    if (readString(json, _vehicleIdPaths) == null &&
        (fallbackVehicleId == null || fallbackVehicleId.trim().isEmpty)) {
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
      gtfsTripId: gtfsTripId,
      routeShortName: routeShortName,
      routeType: routeType,
      headsign: headsign,
      bearing: bearing,
      delaySeconds: delaySeconds,
      statePosition: statePosition,
      lastStopSequence: lastStopSequence,
      shapeDistTraveled: shapeDistTraveled,
      routePoints: routePoints,
      stopTimes: stopTimes,
      vehicleDescriptor: vehicleDescriptor,
      lastUpdated: lastUpdated,
    );
  }
}

const _vehicleIdPaths = [
  ['vehicle_id'],
  ['vehicleId'],
  ['vehicle', 'id'],
  ['vehicle', 'vehicle_id'],
  ['vehicle', 'vehicleId'],
  ['id'],
  ['properties', 'vehicle_id'],
  ['properties', 'vehicleId'],
  ['properties', 'vehicle', 'id'],
  ['properties', 'vehicle', 'vehicle_id'],
  ['properties', 'vehicle', 'vehicleId'],
  ['properties', 'id'],
];

const _bearingPaths = [
  ['bearing'],
  ['bearing_deg'],
  ['properties', 'bearing'],
  ['properties', 'bearing_deg'],
  ['position', 'bearing'],
  ['properties', 'position', 'bearing'],
];

const _gtfsTripIdPaths = [
  ['gtfs_trip_id'],
  ['gtfsTripId'],
  ['trip', 'id'],
  ['trip', 'gtfs_trip_id'],
  ['trip', 'gtfsTripId'],
  ['properties', 'gtfs_trip_id'],
  ['properties', 'gtfsTripId'],
  ['properties', 'trip', 'id'],
  ['properties', 'trip', 'gtfs_trip_id'],
  ['properties', 'trip', 'gtfsTripId'],
];

const _routeShortNamePaths = [
  ['route_short_name'],
  ['routeShortName'],
  ['line'],
  ['route', 'short_name'],
  ['route', 'shortName'],
  ['properties', 'route_short_name'],
  ['properties', 'routeShortName'],
  ['properties', 'line'],
  ['properties', 'route', 'short_name'],
  ['properties', 'route', 'shortName'],
];

const _routeTypePaths = [
  ['route_type'],
  ['routeType'],
  ['route', 'type'],
  ['route', 'route_type'],
  ['route', 'routeType'],
  ['properties', 'route_type'],
  ['properties', 'routeType'],
  ['properties', 'route', 'type'],
  ['properties', 'route', 'route_type'],
  ['properties', 'route', 'routeType'],
];

const _headsignPaths = [
  ['trip_headsign'],
  ['headsign'],
  ['destination'],
  ['trip', 'headsign'],
  ['trip', 'trip_headsign'],
  ['properties', 'trip_headsign'],
  ['properties', 'headsign'],
  ['properties', 'destination'],
  ['properties', 'trip', 'headsign'],
  ['properties', 'trip', 'trip_headsign'],
];

const _delayPaths = [
  ['delay'],
  ['delay_seconds'],
  ['delaySeconds'],
  ['properties', 'delay'],
  ['properties', 'delay_seconds'],
  ['properties', 'delaySeconds'],
];

const _statePositionPaths = [
  ['state_position'],
  ['statePosition'],
  ['properties', 'state_position'],
  ['properties', 'statePosition'],
];

const _lastStopSequencePaths = [
  ['last_stop_sequence'],
  ['lastStopSequence'],
  ['properties', 'last_stop_sequence'],
  ['properties', 'lastStopSequence'],
];

const _shapeDistTraveledPaths = [
  ['shape_dist_traveled'],
  ['shapeDistTraveled'],
  ['properties', 'shape_dist_traveled'],
  ['properties', 'shapeDistTraveled'],
];

const _lastUpdatedPaths = [
  ['last_updated'],
  ['lastUpdated'],
  ['updated_at'],
  ['updatedAt'],
  ['origin_timestamp'],
  ['originTimestamp'],
  ['timestamp'],
  ['properties', 'last_updated'],
  ['properties', 'lastUpdated'],
  ['properties', 'updated_at'],
  ['properties', 'updatedAt'],
  ['properties', 'origin_timestamp'],
  ['properties', 'originTimestamp'],
  ['properties', 'timestamp'],
];

const _stopNamePaths = [
  ['stop_name'],
  ['stopName'],
  ['name'],
  ['properties', 'stop_name'],
  ['properties', 'stopName'],
  ['properties', 'name'],
];

const _stopSequencePaths = [
  ['stop_sequence'],
  ['stopSequence'],
  ['sequence'],
  ['properties', 'stop_sequence'],
  ['properties', 'stopSequence'],
  ['properties', 'sequence'],
];

const _zoneIdPaths = [
  ['zone_id'],
  ['zoneId'],
  ['zone'],
  ['properties', 'zone_id'],
  ['properties', 'zoneId'],
  ['properties', 'zone'],
];

const _arrivalTimePaths = [
  ['arrival_time'],
  ['arrivalTime'],
  ['properties', 'arrival_time'],
  ['properties', 'arrivalTime'],
];

const _departureTimePaths = [
  ['departure_time'],
  ['departureTime'],
  ['properties', 'departure_time'],
  ['properties', 'departureTime'],
];

const _realtimeArrivalTimePaths = [
  ['realtime_arrival_time'],
  ['realtimeArrivalTime'],
  ['properties', 'realtime_arrival_time'],
  ['properties', 'realtimeArrivalTime'],
];

const _realtimeDepartureTimePaths = [
  ['realtime_departure_time'],
  ['realtimeDepartureTime'],
  ['properties', 'realtime_departure_time'],
  ['properties', 'realtimeDepartureTime'],
];

const _wheelchairAccessiblePaths = [
  ['is_wheelchair_accessible'],
  ['isWheelchairAccessible'],
  ['wheelchair_accessible'],
  ['wheelchairAccessible'],
  ['properties', 'is_wheelchair_accessible'],
  ['properties', 'isWheelchairAccessible'],
  ['properties', 'wheelchair_accessible'],
  ['properties', 'wheelchairAccessible'],
];

const _vehicleDescriptorPaths = [
  ['vehicle_descriptor'],
  ['vehicleDescriptor'],
  ['properties', 'vehicle_descriptor'],
  ['properties', 'vehicleDescriptor'],
];

const _vehicleDescriptorOperatorPaths = [
  ['operator'],
  ['operator_name'],
  ['operatorName'],
];

const _vehicleDescriptorTypePaths = [
  ['vehicle_type'],
  ['vehicleType'],
  ['type'],
];

const _vehicleDescriptorAirConditionedPaths = [
  ['is_air_conditioned'],
  ['isAirConditioned'],
  ['air_conditioned'],
  ['airConditioned'],
];

const _vehicleDescriptorUsbChargerPaths = [
  ['has_usb_chargers'],
  ['hasUsbChargers'],
  ['has_charger'],
  ['hasCharger'],
];

const _vehicleDescriptorRegistrationPaths = [
  ['vehicle_registration_number'],
  ['vehicleRegistrationNumber'],
  ['registration_number'],
  ['registrationNumber'],
];

List<VehicleRoutePoint> _parseRoutePoints(JsonMap json) {
  final records = _readNestedRecords(json, const [
    ['shapes'],
    ['shape'],
    ['properties', 'shapes'],
    ['properties', 'shape'],
  ]);
  final points = <VehicleRoutePoint>[];

  for (final record in records) {
    final shapeDistTraveled = readDouble(record, _shapeDistTraveledPaths);
    for (final coordinates in _readGeoJsonPointList(record)) {
      points.add(
        VehicleRoutePoint(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          shapeDistTraveled: shapeDistTraveled,
        ),
      );
    }
  }

  return List<VehicleRoutePoint>.unmodifiable(points);
}

List<VehicleRouteStop> _parseRouteStops(JsonMap json) {
  final records = _readNestedRecords(json, const [
    ['stop_times'],
    ['stopTimes'],
    ['properties', 'stop_times'],
    ['properties', 'stopTimes'],
  ]);
  final stops = <VehicleRouteStop>[];

  for (final record in records) {
    final name = readString(record, _stopNamePaths);
    final coordinates = readGeoJsonPoint(record);

    if (name == null || coordinates == null) {
      continue;
    }

    stops.add(
      VehicleRouteStop(
        name: name,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        stopSequence: readInt(record, _stopSequencePaths),
        zoneId: readString(record, _zoneIdPaths),
        shapeDistTraveled: readDouble(record, _shapeDistTraveledPaths),
        arrivalTime: readDateTime(record, _arrivalTimePaths),
        departureTime: readDateTime(record, _departureTimePaths),
        realtimeArrivalTime: readDateTime(record, _realtimeArrivalTimePaths),
        realtimeDepartureTime: readDateTime(
          record,
          _realtimeDepartureTimePaths,
        ),
        isWheelchairAccessible: readBool(record, _wheelchairAccessiblePaths),
      ),
    );
  }

  return List<VehicleRouteStop>.unmodifiable(stops);
}

VehicleDescriptor? _parseVehicleDescriptor(JsonMap json) {
  final descriptor = asJsonMap(readJsonValue(json, _vehicleDescriptorPaths));
  if (descriptor == null) {
    return null;
  }

  final vehicleDescriptor = VehicleDescriptor(
    operator: readString(descriptor, _vehicleDescriptorOperatorPaths),
    vehicleType: readString(descriptor, _vehicleDescriptorTypePaths),
    isWheelchairAccessible: readBool(descriptor, _wheelchairAccessiblePaths),
    isAirConditioned: readBool(
      descriptor,
      _vehicleDescriptorAirConditionedPaths,
    ),
    hasUsbChargers: readBool(descriptor, _vehicleDescriptorUsbChargerPaths),
    registrationNumber: readString(
      descriptor,
      _vehicleDescriptorRegistrationPaths,
    ),
  );

  if (vehicleDescriptor.operator == null &&
      vehicleDescriptor.vehicleType == null &&
      vehicleDescriptor.isWheelchairAccessible == null &&
      vehicleDescriptor.isAirConditioned == null &&
      vehicleDescriptor.hasUsbChargers == null &&
      vehicleDescriptor.registrationNumber == null) {
    return null;
  }

  return vehicleDescriptor;
}

List<JsonMap> _readNestedRecords(JsonMap json, List<List<String>> paths) {
  final value = readJsonValue(json, paths);

  if (value == null) {
    return <JsonMap>[];
  }

  return readJsonRecords(value);
}

List<ParsedCoordinates> _readGeoJsonPointList(JsonMap json) {
  final coordinates = readJsonValue(json, const [
    ['geometry', 'coordinates'],
    ['properties', 'geometry', 'coordinates'],
  ]);

  if (coordinates is List && coordinates.isNotEmpty) {
    final firstValue = coordinates.first;
    if (firstValue is List) {
      return coordinates
          .map(_coordinatesFromPair)
          .whereType<ParsedCoordinates>()
          .toList(growable: false);
    }
  }

  final point = readGeoJsonPoint(json);
  if (point == null) {
    return <ParsedCoordinates>[];
  }

  return [point];
}

ParsedCoordinates? _coordinatesFromPair(Object? value) {
  if (value is! List || value.length < 2) {
    return null;
  }

  final longitude = _doubleFromValue(value[0]);
  final latitude = _doubleFromValue(value[1]);

  if (!_isValidCoordinate(latitude: latitude, longitude: longitude)) {
    return null;
  }

  return ParsedCoordinates(latitude: latitude!, longitude: longitude!);
}

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

double? _doubleFromValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim());
  }

  return null;
}

bool _isValidCoordinate({
  required double? latitude,
  required double? longitude,
}) {
  if (latitude == null || longitude == null) {
    return false;
  }

  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}
