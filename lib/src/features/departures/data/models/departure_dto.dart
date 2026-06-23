import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/departure.dart';

class DepartureDto {
  const DepartureDto({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.delaySeconds,
    this.platform,
    this.gtfsTripId,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final int? delaySeconds;
  final String? platform;
  final String? gtfsTripId;

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
      delaySeconds: readInt(json, _delayPaths),
      platform: readString(json, _platformPaths),
      gtfsTripId: readString(json, _gtfsTripIdPaths),
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
      delaySeconds: delaySeconds,
      platform: platform,
      gtfsTripId: gtfsTripId,
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
  ['scheduled_departure'],
  ['scheduledDeparture'],
  ['predicted_departure'],
  ['predictedDeparture'],
  ['departure_timestamp'],
  ['properties', 'departure_time'],
  ['properties', 'departureTime'],
  ['properties', 'scheduled_departure'],
  ['properties', 'scheduledDeparture'],
  ['properties', 'predicted_departure'],
  ['properties', 'predictedDeparture'],
  ['properties', 'departure_timestamp'],
  ['departure', 'time'],
  ['departure', 'scheduled'],
  ['departure', 'predicted'],
  ['departure', 'timestamp_scheduled'],
  ['departure', 'timestamp_predicted'],
  ['properties', 'departure', 'time'],
  ['properties', 'departure', 'scheduled'],
  ['properties', 'departure', 'predicted'],
  ['properties', 'departure', 'timestamp_scheduled'],
  ['properties', 'departure', 'timestamp_predicted'],
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
  ['properties', 'platform'],
  ['properties', 'platform_code'],
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
