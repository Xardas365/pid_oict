import 'package:flutter/material.dart';

import 'src/app/pid_oict_shell.dart';
import 'src/features/departures/domain/departure.dart';
import 'src/features/stops/domain/stop.dart';
import 'src/features/vehicle_map/domain/vehicle_position.dart';

const _pidRed = Color(0xFFD32F2F);
const _pidBackground = Color(0xFFFFF8F6);

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _pidRed).copyWith(
          primary: _pidRed,
          surface: Colors.white,
          surfaceContainerLowest: _pidBackground,
        ),
        scaffoldBackgroundColor: _pidBackground,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: _pidBackground,
          foregroundColor: Color(0xFF241B1C),
        ),
      ),
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
