import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/departure.dart';

class DepartureDto {
  const DepartureDto({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.routeType,
    this.delaySeconds,
    this.platform,
    this.stopId,
    this.gtfsTripId,
    this.vehicleId,
    this.isWheelchairAccessible,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final String? routeType;
  final int? delaySeconds;
  final String? platform;
  final String? stopId;
  final String? gtfsTripId;
  final String? vehicleId;
  final bool? isWheelchairAccessible;

  static DepartureDto? fromJson(JsonMap json) {
    final routeShortName = readString(json, _routeShortNamePaths);
    final headsign = readString(json, _headsignPaths);
    final departureTime = readDateTime(json, _departureTimePaths);

    if (routeShortName == null || headsign == null || departureTime == null) {
      return null;
    }

    return DepartureDto(
      routeShortName: routeShortName,
      headsign: headsign,
      departureTime: departureTime,
      routeType: readString(json, _routeTypePaths),
      delaySeconds: readInt(json, _delayPaths),
      platform: readString(json, _platformPaths),
      stopId: readString(json, _stopIdPaths),
      gtfsTripId: readString(json, _gtfsTripIdPaths),
      vehicleId: readString(json, _vehicleIdPaths),
      isWheelchairAccessible: readBool(json, _wheelchairAccessiblePaths),
    );
  }

  static ParsedResult<DepartureDto> parseWithDiagnostics(Object? response) {
    return parseJsonRecordsWithDiagnostics<DepartureDto>(
      response: response,
      parse: DepartureDto.fromJson,
      skipReason: invalidReason,
    );
  }

  static String invalidReason(JsonMap json) {
    if (readString(json, _routeShortNamePaths) == null) {
      return 'missing route short name';
    }

    if (readString(json, _headsignPaths) == null) {
      return 'missing headsign';
    }

    if (readDateTime(json, _departureTimePaths) == null) {
      return 'missing or invalid departure time';
    }

    return 'invalid departure record';
  }

  Departure toDomain() {
    return Departure(
      routeShortName: routeShortName,
      headsign: headsign,
      departureTime: departureTime,
      routeType: routeType,
      delaySeconds: delaySeconds,
      platform: platform,
      stopId: stopId,
      gtfsTripId: gtfsTripId,
      vehicleId: vehicleId,
      isWheelchairAccessible: isWheelchairAccessible,
    );
  }
}

const _routeShortNamePaths = [
  ['route_short_name'],
  ['routeShortName'],
  ['line'],
  ['properties', 'route_short_name'],
  ['properties', 'routeShortName'],
  ['properties', 'line'],
  ['route', 'short_name'],
  ['route', 'shortName'],
  ['properties', 'route', 'short_name'],
  ['properties', 'route', 'shortName'],
];

const _routeTypePaths = [
  ['route_type'],
  ['routeType'],
  ['type'],
  ['properties', 'route_type'],
  ['properties', 'routeType'],
  ['properties', 'type'],
  ['route', 'type'],
  ['route', 'route_type'],
  ['route', 'routeType'],
  ['properties', 'route', 'type'],
  ['properties', 'route', 'route_type'],
  ['properties', 'route', 'routeType'],
];

const _headsignPaths = [
  ['headsign'],
  ['destination'],
  ['trip_headsign'],
  ['properties', 'headsign'],
  ['properties', 'destination'],
  ['properties', 'trip_headsign'],
  ['trip', 'headsign'],
  ['trip', 'trip_headsign'],
  ['properties', 'trip', 'headsign'],
  ['properties', 'trip', 'trip_headsign'],
];

const _departureTimePaths = [
  ['departure_time'],
  ['departureTime'],
  ['predicted_departure'],
  ['predictedDeparture'],
  ['scheduled_departure'],
  ['scheduledDeparture'],
  ['departure_timestamp'],
  ['properties', 'departure_time'],
  ['properties', 'departureTime'],
  ['properties', 'predicted_departure'],
  ['properties', 'predictedDeparture'],
  ['properties', 'scheduled_departure'],
  ['properties', 'scheduledDeparture'],
  ['properties', 'departure_timestamp'],
  ['departure', 'time'],
  ['departure', 'predicted'],
  ['departure', 'timestamp_predicted'],
  ['departure', 'scheduled'],
  ['departure', 'timestamp_scheduled'],
  ['properties', 'departure', 'time'],
  ['properties', 'departure', 'predicted'],
  ['properties', 'departure', 'timestamp_predicted'],
  ['properties', 'departure', 'scheduled'],
  ['properties', 'departure', 'timestamp_scheduled'],
];

const _delayPaths = [
  ['delay_seconds'],
  ['delaySeconds'],
  ['delay'],
  ['properties', 'delay_seconds'],
  ['properties', 'delaySeconds'],
  ['properties', 'delay'],
  ['departure', 'delay_seconds'],
  ['departure', 'delaySeconds'],
  ['departure', 'delay'],
  ['properties', 'departure', 'delay_seconds'],
  ['properties', 'departure', 'delaySeconds'],
  ['properties', 'departure', 'delay'],
];

const _platformPaths = [
  ['platform'],
  ['platform_code'],
  ['stop', 'platform_code'],
  ['properties', 'platform'],
  ['properties', 'platform_code'],
  ['properties', 'stop', 'platform_code'],
];

const _stopIdPaths = [
  ['stop_id'],
  ['stopId'],
  ['stop', 'id'],
  ['stop', 'stop_id'],
  ['properties', 'stop_id'],
  ['properties', 'stopId'],
  ['properties', 'stop', 'id'],
  ['properties', 'stop', 'stop_id'],
];

const _gtfsTripIdPaths = [
  ['departure', 'trip', 'id'],
  ['departure', 'trip', 'gtfs_trip_id'],
  ['departure', 'trip', 'gtfsTripId'],
  ['trip', 'id'],
  ['trip', 'gtfs_trip_id'],
  ['trip', 'gtfsTripId'],
  ['gtfs_trip_id'],
  ['gtfsTripId'],
  ['properties', 'departure', 'trip', 'id'],
  ['properties', 'departure', 'trip', 'gtfs_trip_id'],
  ['properties', 'departure', 'trip', 'gtfsTripId'],
  ['properties', 'trip', 'id'],
  ['properties', 'trip', 'gtfs_trip_id'],
  ['properties', 'trip', 'gtfsTripId'],
  ['properties', 'gtfs_trip_id'],
  ['properties', 'gtfsTripId'],
];

const _vehicleIdPaths = [
  ['vehicle_id'],
  ['vehicleId'],
  ['vehicle', 'id'],
  ['vehicle', 'vehicle_id'],
  ['vehicle', 'vehicleId'],
  ['properties', 'vehicle_id'],
  ['properties', 'vehicleId'],
  ['properties', 'vehicle', 'id'],
  ['properties', 'vehicle', 'vehicle_id'],
  ['properties', 'vehicle', 'vehicleId'],
  ['departure', 'vehicle', 'id'],
  ['departure', 'vehicle', 'vehicle_id'],
  ['departure', 'vehicle', 'vehicleId'],
  ['properties', 'departure', 'vehicle', 'id'],
  ['properties', 'departure', 'vehicle', 'vehicle_id'],
  ['properties', 'departure', 'vehicle', 'vehicleId'],
];

const _wheelchairAccessiblePaths = [
  ['is_wheelchair_accessible'],
  ['isWheelchairAccessible'],
  ['wheelchair_accessible'],
  ['wheelchairAccessible'],
  ['vehicle', 'is_wheelchair_accessible'],
  ['vehicle', 'isWheelchairAccessible'],
  ['vehicle', 'wheelchair_accessible'],
  ['vehicle', 'wheelchairAccessible'],
  ['properties', 'is_wheelchair_accessible'],
  ['properties', 'isWheelchairAccessible'],
  ['properties', 'wheelchair_accessible'],
  ['properties', 'wheelchairAccessible'],
  ['properties', 'vehicle', 'is_wheelchair_accessible'],
  ['properties', 'vehicle', 'isWheelchairAccessible'],
  ['properties', 'vehicle', 'wheelchair_accessible'],
  ['properties', 'vehicle', 'wheelchairAccessible'],
  ['departure', 'vehicle', 'is_wheelchair_accessible'],
  ['departure', 'vehicle', 'isWheelchairAccessible'],
  ['properties', 'departure', 'vehicle', 'is_wheelchair_accessible'],
  ['properties', 'departure', 'vehicle', 'isWheelchairAccessible'],
];
