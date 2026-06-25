import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

const andelStop = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U123S1',
  wheelchairBoarding: 2,
  levelId: 'U123L2',
  latitude: 50.07128,
  longitude: 14.40312,
);

const staromestskaStop = Stop(
  id: 'U456Z2',
  name: 'Staromestska',
  platformCode: 'B',
  zoneId: 'P',
  locationType: 0,
  parentStationId: 'U456S1',
  wheelchairBoarding: 2,
  levelId: 'U456L2',
  latitude: 50.08708,
  longitude: 14.42078,
);

const technicalStop = Stop(id: 'TECH1', name: 'hr.VUSC Praha');

final andelStopGroup = StopGroup.single(andelStop);
final staromestskaStopGroup = StopGroup.single(staromestskaStop);

Departure repyDeparture({
  String? gtfsTripId = 'trip-10-repy',
  String? vehicleId = 'service-3-1001',
}) {
  return Departure(
    routeShortName: '10',
    headsign: 'Sidliste Repy',
    departureTime: DateTime(2026, 6, 22, 10, 15),
    delaySeconds: 60,
    platform: '3',
    gtfsTripId: gtfsTripId,
    vehicleId: vehicleId,
  );
}

Departure motolDeparture({String? gtfsTripId, String? vehicleId}) {
  return Departure(
    routeShortName: 'A',
    headsign: 'Nemocnice Motol',
    departureTime: DateTime(2026, 6, 22, 10, 18),
    gtfsTripId: gtfsTripId,
    vehicleId: vehicleId,
  );
}

VehiclePosition andelVehiclePosition({
  String vehicleId = 'vehicle-999',
  double latitude = 50.0755,
  double longitude = 14.4378,
}) {
  return VehiclePosition(
    vehicleId: vehicleId,
    latitude: latitude,
    longitude: longitude,
    routeShortName: '10',
    routeType: 'tram',
    headsign: 'Sidliste Repy',
    delaySeconds: 60,
    shapeDistTraveled: 1200,
    lastStopSequence: 2,
    routePoints: const [
      VehicleRoutePoint(
        latitude: 50.0748,
        longitude: 14.4358,
        shapeDistTraveled: 900,
      ),
      VehicleRoutePoint(
        latitude: 50.0755,
        longitude: 14.4378,
        shapeDistTraveled: 1200,
      ),
      VehicleRoutePoint(
        latitude: 50.0763,
        longitude: 14.4402,
        shapeDistTraveled: 1500,
      ),
    ],
    stopTimes: const [
      VehicleRouteStop(
        name: 'Andel',
        latitude: 50.0748,
        longitude: 14.4358,
        stopSequence: 1,
        zoneId: 'P',
        shapeDistTraveled: 900,
      ),
      VehicleRouteStop(
        name: 'Zborovska',
        latitude: 50.0755,
        longitude: 14.4378,
        stopSequence: 2,
        zoneId: 'P',
        shapeDistTraveled: 1200,
      ),
    ],
    lastUpdated: DateTime(2026, 6, 22, 10, 20),
  );
}
