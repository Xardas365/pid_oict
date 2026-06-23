import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../i18n/strings.g.dart';
import '../features/departures/domain/departure.dart';
import '../features/departures/presentation/departures_screen.dart';
import '../features/stops/domain/stop.dart';
import '../features/stops/presentation/stops_screen.dart';
import '../features/vehicle_map/domain/vehicle_position.dart';
import '../features/vehicle_map/presentation/vehicle_map_screen.dart';
import '../shared/widgets/empty_state_view.dart';

class PidOictShell extends StatefulWidget {
  const PidOictShell({
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
  State<PidOictShell> createState() => _PidOictShellState();
}

class _PidOictShellState extends State<PidOictShell> {
  var _selectedTab = PidNavigationTab.stops;
  Stop? _selectedStop;
  String? _selectedVehicleId;

  void _selectStop(Stop stop) {
    setState(() {
      _selectedStop = stop;
      _selectedTab = PidNavigationTab.departures;
    });
  }

  void _selectVehicle(String vehicleId) {
    setState(() {
      _selectedVehicleId = vehicleId;
      _selectedTab = PidNavigationTab.map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t;

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          StopsScreen(loadStops: widget.loadStops, onStopSelected: _selectStop),
          _DeparturesTab(
            selectedStop: _selectedStop,
            loadDepartures: widget.loadDepartures,
            onVehicleSelected: _selectVehicle,
          ),
          _MapTab(
            selectedVehicleId: _selectedVehicleId,
            loadVehiclePosition: widget.loadVehiclePosition,
            refreshInterval: widget.vehicleMapRefreshInterval,
            showMapTiles: widget.showMapTiles,
            isActive: _selectedTab == PidNavigationTab.map,
          ),
        ],
      ),
      bottomNavigationBar: PidBottomNavigation(
        selectedTab: _selectedTab,
        labelBuilder: (tab) => switch (tab) {
          PidNavigationTab.stops => strings.navigation.stops,
          PidNavigationTab.departures => strings.navigation.departures,
          PidNavigationTab.map => strings.navigation.map,
        },
        onTabSelected: (tab) {
          setState(() {
            _selectedTab = tab;
          });
        },
      ),
    );
  }
}

class _DeparturesTab extends StatelessWidget {
  const _DeparturesTab({
    required this.selectedStop,
    required this.loadDepartures,
    required this.onVehicleSelected,
  });

  final Stop? selectedStop;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final ValueChanged<String> onVehicleSelected;

  @override
  Widget build(BuildContext context) {
    final stop = selectedStop;
    if (stop == null) {
      final strings = context.t;

      return _ShellEmptyTab(
        title: strings.navigation.departures,
        message: strings.departures.emptyTabMessage,
        icon: Icons.departure_board_outlined,
      );
    }

    return DeparturesScreen(
      key: ValueKey(stop.id),
      stop: stop,
      loadDepartures: loadDepartures,
      onVehicleSelected: onVehicleSelected,
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.selectedVehicleId,
    required this.loadVehiclePosition,
    required this.refreshInterval,
    required this.showMapTiles,
    required this.isActive,
  });

  final String? selectedVehicleId;
  final Future<VehiclePosition> Function(String vehicleId)? loadVehiclePosition;
  final Duration refreshInterval;
  final bool showMapTiles;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final vehicleId = selectedVehicleId;
    if (vehicleId == null) {
      final strings = context.t;

      return _ShellEmptyTab(
        title: strings.navigation.map,
        message: strings.vehicleMap.emptyTabMessage,
        icon: Icons.map_outlined,
      );
    }

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return VehicleMapScreen(
      key: ValueKey(vehicleId),
      vehicleId: vehicleId,
      loadVehiclePosition: loadVehiclePosition,
      refreshInterval: refreshInterval,
      showMapTiles: showMapTiles,
    );
  }
}

class _ShellEmptyTab extends StatelessWidget {
  const _ShellEmptyTab({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: EmptyStateView(message: message, icon: icon),
      ),
    );
  }
}
