import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

const andelStop = Stop(
  id: 'U123Z1',
  name: 'Andel',
  platformCode: 'A',
  latitude: 50.07128,
  longitude: 14.40312,
);

const staromestskaStop = Stop(
  id: 'U456Z2',
  name: 'Staromestska',
  platformCode: 'B',
  latitude: 50.08708,
  longitude: 14.42078,
);

const technicalStop = Stop(id: 'TECH1', name: 'hr.VUSC Praha');

Departure repyDeparture({String? gtfsTripId = 'trip-10-repy'}) {
  return Departure(
    routeShortName: '10',
    headsign: 'Sidliste Repy',
    departureTime: DateTime(2026, 6, 22, 10, 15),
    delaySeconds: 60,
    platform: '3',
    gtfsTripId: gtfsTripId,
  );
}

Departure motolDeparture({String? gtfsTripId}) {
  return Departure(
    routeShortName: 'A',
    headsign: 'Nemocnice Motol',
    departureTime: DateTime(2026, 6, 22, 10, 18),
    gtfsTripId: gtfsTripId,
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
    lastUpdated: DateTime(2026, 6, 22, 10, 20),
  );
}
