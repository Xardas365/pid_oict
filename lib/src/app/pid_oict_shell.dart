import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../i18n/strings.g.dart';
import '../features/departures/domain/usecases/load_departure_board_use_case.dart';
import '../features/departures/presentation/bloc/departures_bloc.dart';
import '../features/departures/presentation/bloc/departures_event.dart';
import '../features/departures/presentation/departures_screen.dart';
import '../features/stops/domain/stop_group.dart';
import '../features/stops/domain/usecases/get_stops_use_case.dart';
import '../features/stops/domain/usecases/load_cached_stops_use_case.dart';
import '../features/stops/domain/usecases/load_complete_stop_index_use_case.dart';
import '../features/stops/domain/usecases/load_saved_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/load_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/record_recent_stop_use_case.dart';
import '../features/stops/domain/usecases/refresh_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/save_stops_cache_use_case.dart';
import '../features/stops/domain/usecases/search_stop_groups_use_case.dart';
import '../features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';
import '../features/stops/presentation/cubit/stops_cubit.dart';
import '../features/stops/presentation/stops_screen.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../features/vehicle_map/presentation/vehicle_map_args.dart';
import '../features/vehicle_map/presentation/vehicle_map_screen.dart';
import '../shared/widgets/empty_state_view.dart';

class PidOictShell extends StatefulWidget {
  const PidOictShell({
    super.key,
    this.departureRefreshInterval = departureBoardRefreshInterval,
    this.vehicleMapRefreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final Duration departureRefreshInterval;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  State<PidOictShell> createState() => _PidOictShellState();
}

class _PidOictShellState extends State<PidOictShell> {
  PidNavigationTab _selectedTab = PidNavigationTab.stops;
  StopGroup? _selectedStop;
  VehicleMapArgs? _selectedVehicleMapArgs;

  void _selectStop(StopGroup stop) {
    setState(() {
      _selectedStop = stop;
      _selectedTab = PidNavigationTab.departures;
    });
  }

  void _selectVehicle(VehicleMapArgs args) {
    setState(() {
      _selectedVehicleMapArgs = args;
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
          _StopsTab(onStopSelected: _selectStop),
          _DeparturesTab(
            selectedStop: _selectedStop,
            refreshInterval: widget.departureRefreshInterval,
            onVehicleSelected: _selectVehicle,
            onBackToStops: _showStops,
            isActive: _selectedTab == PidNavigationTab.departures,
          ),
          _MapTab(
            args: _selectedVehicleMapArgs,
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
  const _StopsTab({required this.onStopSelected});

  final ValueChanged<StopGroup> onStopSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = StopsCubit(
          context.read<GetStopsUseCase>(),
          loadStopGroups: context.read<LoadStopGroupsUseCase>(),
          refreshStopGroups: context.read<RefreshStopGroupsUseCase>(),
          loadCompleteStopIndex: context.read<LoadCompleteStopIndexUseCase>(),
          searchStopGroups: context.read<SearchStopGroupsUseCase>(),
          loadCachedStops: context.read<LoadCachedStopsUseCase>(),
          saveStopsCache: context.read<SaveStopsCacheUseCase>(),
          loadSavedStopGroups: context.read<LoadSavedStopGroupsUseCase>(),
          toggleFavoriteStop: context.read<ToggleFavoriteStopUseCase>(),
          recordRecentStopUseCase: context.read<RecordRecentStopUseCase>(),
        );
        unawaited(cubit.loadStops());
        return cubit;
      },
      child: StopsScreen(onStopSelected: onStopSelected),
    );
  }
}

class _DeparturesTab extends StatelessWidget {
  const _DeparturesTab({
    required this.selectedStop,
    required this.refreshInterval,
    required this.onVehicleSelected,
    required this.onBackToStops,
    required this.isActive,
  });

  final StopGroup? selectedStop;
  final Duration refreshInterval;
  final ValueChanged<VehicleMapArgs> onVehicleSelected;
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
        context.read<LoadDepartureBoardUseCase>(),
        refreshInterval: refreshInterval,
      )..add(DeparturesStarted(stop)),
      child: DeparturesScreen(
        stop: stop,
        onVehicleSelected: onVehicleSelected,
        onBackToStops: onBackToStops,
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.args,
    required this.refreshInterval,
    required this.showMapTiles,
    required this.isActive,
  });

  final VehicleMapArgs? args;
  final Duration refreshInterval;
  final bool showMapTiles;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final args = this.args;
    if (args == null) {
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
      key: ValueKey(args.vehicleId.value),
      create: (context) => VehicleMapBloc(
        context.read<GetVehiclePositionForVehicleUseCase>(),
        pollingInterval: refreshInterval,
      )..add(VehicleMapStarted(args.vehicleId)),
      child: VehicleMapScreen(args: args, showMapTiles: showMapTiles),
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
