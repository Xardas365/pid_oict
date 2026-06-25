import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../i18n/strings.g.dart';
import '../features/departures/domain/departure.dart';
import '../features/departures/domain/repositories/departures_repository.dart';
import '../features/departures/domain/usecases/load_departure_board_use_case.dart';
import '../features/departures/domain/usecases/refresh_departure_board_use_case.dart';
import '../features/departures/presentation/bloc/departures_bloc.dart';
import '../features/departures/presentation/bloc/departures_event.dart';
import '../features/departures/presentation/departures_screen.dart';
import '../features/stops/domain/repositories/stops_repository.dart';
import '../features/stops/domain/stop.dart';
import '../features/stops/domain/stop_group.dart';
import '../features/stops/domain/usecases/get_stops_use_case.dart';
import '../features/stops/domain/usecases/load_cached_stops_use_case.dart';
import '../features/stops/domain/usecases/load_saved_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/load_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/record_recent_stop_use_case.dart';
import '../features/stops/domain/usecases/refresh_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/save_stops_cache_use_case.dart';
import '../features/stops/domain/usecases/search_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';
import '../features/stops/presentation/cubit/stops_cubit.dart';
import '../features/stops/presentation/stops_screen.dart';
import '../features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../features/vehicle_map/domain/vehicle_position.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../features/vehicle_map/presentation/vehicle_map_screen.dart';
import '../shared/widgets/empty_state_view.dart';

class PidOictShell extends StatefulWidget {
  const PidOictShell({
    super.key,
    this.loadStops,
    this.loadDepartures,
    this.loadVehiclePosition,
    this.departureRefreshInterval = departureBoardRefreshInterval,
    this.vehicleMapRefreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final Future<List<Stop>> Function()? loadStops;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final Future<VehiclePosition> Function(String vehicleId)? loadVehiclePosition;
  final Duration departureRefreshInterval;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  State<PidOictShell> createState() => _PidOictShellState();
}

class _PidOictShellState extends State<PidOictShell> {
  PidNavigationTab _selectedTab = PidNavigationTab.stops;
  StopGroup? _selectedStop;
  String? _selectedVehicleId;

  void _selectStop(StopGroup stop) {
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

  void _showStops() {
    setState(() {
      _selectedTab = PidNavigationTab.stops;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t;

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          _StopsTab(loadStops: widget.loadStops, onStopSelected: _selectStop),
          _DeparturesTab(
            selectedStop: _selectedStop,
            loadDepartures: widget.loadDepartures,
            refreshInterval: widget.departureRefreshInterval,
            onVehicleSelected: _selectVehicle,
            onBackToStops: _showStops,
            isActive: _selectedTab == PidNavigationTab.departures,
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

class _StopsTab extends StatelessWidget {
  const _StopsTab({required this.loadStops, required this.onStopSelected});

  final Future<List<Stop>> Function()? loadStops;
  final ValueChanged<StopGroup> onStopSelected;

  @override
  Widget build(BuildContext context) {
    final loadStops = this.loadStops;

    return BlocProvider(
      create: (context) {
        final cubit = StopsCubit(
          _getStopsUseCase(context),
          loadStopGroups: loadStops == null
              ? context.read<LoadStopGroupsUseCase>()
              : null,
          refreshStopGroups: loadStops == null
              ? context.read<RefreshStopGroupsUseCase>()
              : null,
          searchStopGroups: loadStops == null
              ? context.read<SearchStopGroupsUseCase>()
              : null,
          loadCachedStops: loadStops == null
              ? context.read<LoadCachedStopsUseCase>()
              : null,
          saveStopsCache: loadStops == null
              ? context.read<SaveStopsCacheUseCase>()
              : null,
          loadSavedStopGroups: loadStops == null
              ? context.read<LoadSavedStopGroupsUseCase>()
              : null,
          toggleFavoriteStop: loadStops == null
              ? context.read<ToggleFavoriteStopUseCase>()
              : null,
          recordRecentStopUseCase: loadStops == null
              ? context.read<RecordRecentStopUseCase>()
              : null,
        );
        unawaited(cubit.loadStops());
        return cubit;
      },
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
    required this.refreshInterval,
    required this.onVehicleSelected,
    required this.onBackToStops,
    required this.isActive,
  });

  final StopGroup? selectedStop;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final Duration refreshInterval;
  final ValueChanged<String> onVehicleSelected;
  final VoidCallback onBackToStops;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const SizedBox.shrink();
    }

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
      create: (context) => DeparturesBloc(
        _loadDepartureBoardUseCase(context),
        refreshDepartureBoard: _refreshDepartureBoardUseCase(context),
        refreshInterval: refreshInterval,
      )..add(DeparturesStarted(stop)),
      child: DeparturesScreen(
        stop: stop,
        onVehicleSelected: onVehicleSelected,
        onBackToStops: onBackToStops,
      ),
    );
  }

  LoadDepartureBoardUseCase _loadDepartureBoardUseCase(BuildContext context) {
    final loadDepartures = this.loadDepartures;
    if (loadDepartures != null) {
      return LoadDepartureBoardUseCase(
        _CallbackDeparturesRepository(loadDepartures),
      );
    }

    return context.read<LoadDepartureBoardUseCase>();
  }

  RefreshDepartureBoardUseCase _refreshDepartureBoardUseCase(
    BuildContext context,
  ) {
    final loadDepartures = this.loadDepartures;
    if (loadDepartures != null) {
      return RefreshDepartureBoardUseCase(
        _CallbackDeparturesRepository(loadDepartures),
      );
    }

    return context.read<RefreshDepartureBoardUseCase>();
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
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) {
    return _loadDepartures(stop.representativeStop);
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

    return BlocProvider(
      key: ValueKey(vehicleId),
      create: (context) => VehicleMapBloc(
        _getVehiclePositionUseCase(context),
        pollingInterval: refreshInterval,
      )..add(VehicleMapStarted(vehicleId)),
      child: VehicleMapScreen(vehicleId: vehicleId, showMapTiles: showMapTiles),
    );
  }

  GetVehiclePositionForVehicleUseCase _getVehiclePositionUseCase(
    BuildContext context,
  ) {
    final loadVehiclePosition = this.loadVehiclePosition;
    if (loadVehiclePosition != null) {
      return GetVehiclePositionForVehicleUseCase(
        _CallbackVehiclePositionRepository(loadVehiclePosition),
      );
    }

    return context.read<GetVehiclePositionForVehicleUseCase>();
  }
}

class _CallbackVehiclePositionRepository implements VehiclePositionRepository {
  const _CallbackVehiclePositionRepository(this._loadVehiclePosition);

  final Future<VehiclePosition> Function(String vehicleId) _loadVehiclePosition;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String vehicleId) {
    return _loadVehiclePosition(vehicleId);
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
