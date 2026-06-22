import '../../../../shared/utils/json_parsing.dart';
import '../../domain/departure.dart';

class DepartureDto {
  const DepartureDto({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.delaySeconds,
    this.platform,
    this.vehicleId,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final int? delaySeconds;
  final String? platform;
  final String? vehicleId;

  static DepartureDto? fromJson(JsonMap json) {
    final routeShortName = readString(json, [
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
    ]);
    final headsign = readString(json, [
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
    ]);
    final departureTime = readDateTime(json, [
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
    ]);

    if (routeShortName == null || headsign == null || departureTime == null) {
      return null;
    }

    return DepartureDto(
      routeShortName: routeShortName,
      headsign: headsign,
      departureTime: departureTime,
      delaySeconds: readInt(json, [
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
      ]),
      platform: readString(json, [
        ['platform'],
        ['platform_code'],
        ['properties', 'platform'],
        ['properties', 'platform_code'],
      ]),
      vehicleId: readString(json, [
        ['vehicle_id'],
        ['vehicleId'],
        ['properties', 'vehicle_id'],
        ['properties', 'vehicleId'],
        ['vehicle', 'id'],
        ['properties', 'vehicle', 'id'],
      ]),
    );
  }

  Departure toDomain() {
    return Departure(
      routeShortName: routeShortName,
      headsign: headsign,
      departureTime: departureTime,
      delaySeconds: delaySeconds,
      platform: platform,
      vehicleId: vehicleId,
    );
  }
}
