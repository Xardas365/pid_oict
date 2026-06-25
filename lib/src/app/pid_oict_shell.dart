import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../features/stops/domain/usecases/remote_supplement_stop_search_use_case.dart';
import '../features/stops/domain/usecases/save_stops_cache_use_case.dart';
import '../features/stops/domain/usecases/toggle_favorite_stop_use_case.dart';
import '../features/stops/presentation/cubit/stops_cubit.dart';
import '../features/stops/presentation/stops_screen.dart';
import '../features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../features/vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../features/vehicle_map/presentation/vehicle_map_args.dart';
import '../features/vehicle_map/presentation/vehicle_map_screen.dart';

enum _ShellPage { stops, departures }

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
  _ShellPage _selectedPage = _ShellPage.stops;
  StopGroup? _selectedStop;

  void _selectStop(StopGroup stop) {
    setState(() {
      _selectedStop = stop;
      _selectedPage = _ShellPage.departures;
    });
  }

  void _showStops() {
    setState(() {
      _selectedPage = _ShellPage.stops;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _selectedPage.index,
      children: [
        _StopsTab(onStopSelected: _selectStop),
        _DeparturesTab(
          selectedStop: _selectedStop,
          departureRefreshInterval: widget.departureRefreshInterval,
          vehicleMapRefreshInterval: widget.vehicleMapRefreshInterval,
          showMapTiles: widget.showMapTiles,
          onBackToStops: _showStops,
          isActive: _selectedPage == _ShellPage.departures,
        ),
      ],
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
          remoteSupplementStopSearch: context
              .read<RemoteSupplementStopSearchUseCase>(),
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
    required this.departureRefreshInterval,
    required this.vehicleMapRefreshInterval,
    required this.showMapTiles,
    required this.onBackToStops,
    required this.isActive,
  });

  final StopGroup? selectedStop;
  final Duration departureRefreshInterval;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;
  final VoidCallback onBackToStops;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const SizedBox.shrink();
    }

    final stop = selectedStop;
    if (stop == null) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      key: ValueKey(stop.id),
      create: (context) => DeparturesBloc(
        context.read<LoadDepartureBoardUseCase>(),
        refreshInterval: departureRefreshInterval,
      )..add(DeparturesStarted(stop)),
      child: DeparturesScreen(
        stop: stop,
        onVehicleSelected: (args) => _openVehicleMap(context, args),
        onBackToStops: onBackToStops,
      ),
    );
  }

  void _openVehicleMap(BuildContext context, VehicleMapArgs args) {
    final getVehiclePosition = context
        .read<GetVehiclePositionForVehicleUseCase>();

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => VehicleMapBloc(
              getVehiclePosition,
              pollingInterval: vehicleMapRefreshInterval,
            )..add(VehicleMapStarted(args.vehicleId)),
            child: VehicleMapScreen(args: args, showMapTiles: showMapTiles),
          ),
        ),
      ),
    );
  }
}
