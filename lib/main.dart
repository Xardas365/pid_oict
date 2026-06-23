import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

import 'src/app/pid_oict_shell.dart';
import 'src/features/departures/domain/departure.dart';
import 'src/features/stops/domain/stop.dart';
import 'src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  runApp(const PidOictApp());
}

class PidOictApp extends StatelessWidget {
  const PidOictApp({
    super.key,
    this.loadStops,
    this.loadDepartures,
    this.loadVehiclePosition,
    this.vehicleMapRefreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final Future<List<Stop>> Function()? loadStops;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final Future<VehiclePosition> Function(String vehicleId)? loadVehiclePosition;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PID Odjezdy',
      theme: PidSeedsTheme.light(),
      home: PidOictShell(
        loadStops: loadStops,
        loadDepartures: loadDepartures,
        loadVehiclePosition: loadVehiclePosition,
        vehicleMapRefreshInterval: vehicleMapRefreshInterval,
        showMapTiles: showMapTiles,
      ),
    );
  }
}
