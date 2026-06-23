import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../i18n/strings.g.dart';
import '../features/departures/domain/departure.dart';
import '../features/departures/domain/repositories/departures_repository.dart';
import '../features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import '../features/departures/presentation/bloc/departures_bloc.dart';
import '../features/departures/presentation/bloc/departures_event.dart';
import '../features/departures/presentation/departures_screen.dart';
import '../features/stops/domain/repositories/stops_repository.dart';
import '../features/stops/domain/stop.dart';
import '../features/stops/domain/usecases/get_stops_use_case.dart';
import '../features/stops/presentation/cubit/stops_cubit.dart';
import '../features/stops/presentation/stops_screen.dart';
import '../features/vehicle_map/domain/vehicle_position.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_trip_use_case.dart';
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
  final Future<VehiclePosition> Function(String gtfsTripId)?
  loadVehiclePosition;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  State<PidOictShell> createState() => _PidOictShellState();
}

class _PidOictShellState extends State<PidOictShell> {
  var _selectedTab = PidNavigationTab.stops;
  Stop? _selectedStop;
  String? _selectedGtfsTripId;

  void _selectStop(Stop stop) {
    setState(() {
      _selectedStop = stop;
      _selectedTab = PidNavigationTab.departures;
    });
  }

  void _selectTrip(String gtfsTripId) {
    setState(() {
      _selectedGtfsTripId = gtfsTripId;
      _selectedTab = PidNavigationTab.map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t;
    final loadVehiclePosition =
        widget.loadVehiclePosition ??
        (gtfsTripId) =>
            context.read<GetVehiclePositionForTripUseCase>()(gtfsTripId);

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          _StopsTab(loadStops: widget.loadStops, onStopSelected: _selectStop),
          _DeparturesTab(
            selectedStop: _selectedStop,
            loadDepartures: widget.loadDepartures,
            onTripSelected: _selectTrip,
          ),
          _MapTab(
            selectedGtfsTripId: _selectedGtfsTripId,
            loadVehiclePosition: loadVehiclePosition,
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

class _StopsTab extends StatelessWidget {
  const _StopsTab({required this.loadStops, required this.onStopSelected});

  final Future<List<Stop>> Function()? loadStops;
  final ValueChanged<Stop> onStopSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StopsCubit(_getStopsUseCase(context))..loadStops(),
      child: StopsScreen(onStopSelected: onStopSelected),
    );
  }

  GetStopsUseCase _getStopsUseCase(BuildContext context) {
    final loadStops = this.loadStops;
    if (loadStops != null) {
      return GetStopsUseCase(_CallbackStopsRepository(loadStops));
    }

    return context.read<GetStopsUseCase>();
  }
}

class _DeparturesTab extends StatelessWidget {
  const _DeparturesTab({
    required this.selectedStop,
    required this.loadDepartures,
    required this.onTripSelected,
  });

  final Stop? selectedStop;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final ValueChanged<String> onTripSelected;

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

    return BlocProvider(
      key: ValueKey(stop.id),
      create: (context) =>
          DeparturesBloc(_getDeparturesUseCase(context))
            ..add(DeparturesStarted(stop)),
      child: DeparturesScreen(stop: stop, onTripSelected: onTripSelected),
    );
  }

  GetDeparturesForStopUseCase _getDeparturesUseCase(BuildContext context) {
    final loadDepartures = this.loadDepartures;
    if (loadDepartures != null) {
      return GetDeparturesForStopUseCase(
        _CallbackDeparturesRepository(loadDepartures),
      );
    }

    return context.read<GetDeparturesForStopUseCase>();
  }
}

class _CallbackStopsRepository implements StopsRepository {
  const _CallbackStopsRepository(this._loadStops);

  final Future<List<Stop>> Function() _loadStops;

  @override
  Future<List<Stop>> fetchStops() {
    return _loadStops();
  }
}

class _CallbackDeparturesRepository implements DeparturesRepository {
  const _CallbackDeparturesRepository(this._loadDepartures);

  final Future<List<Departure>> Function(Stop stop) _loadDepartures;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) {
    return _loadDepartures(stop);
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.selectedGtfsTripId,
    required this.loadVehiclePosition,
    required this.refreshInterval,
    required this.showMapTiles,
    required this.isActive,
  });

  final String? selectedGtfsTripId;
  final Future<VehiclePosition> Function(String gtfsTripId)?
  loadVehiclePosition;
  final Duration refreshInterval;
  final bool showMapTiles;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final gtfsTripId = selectedGtfsTripId;
    if (gtfsTripId == null) {
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
      key: ValueKey(gtfsTripId),
      gtfsTripId: gtfsTripId,
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
