import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/domain/pid_line_type.dart';
import '../../../core/presentation/widgets/pid_transport_icon.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/utils/date_time_formatters.dart';
import '../../../shared/widgets/centered_scroll_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../../stops/domain/stop_group.dart';
import '../../vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../../vehicle_map/presentation/vehicle_map_screen.dart';
import '../domain/departure.dart';
import 'bloc/departures_bloc.dart';
import 'bloc/departures_event.dart';
import 'bloc/departures_state.dart';
import 'widgets/departure_tile.dart';

class DeparturesScreen extends StatelessWidget {
  const DeparturesScreen({
    required this.stop,
    super.key,
    this.onVehicleSelected,
    this.onBackToStops,
  });

  final StopGroup stop;
  final ValueChanged<String>? onVehicleSelected;
  final VoidCallback? onBackToStops;

  void _backToStops(BuildContext context) {
    final onBackToStops = this.onBackToStops;
    if (onBackToStops != null) {
      onBackToStops();
      return;
    }

    unawaited(Navigator.of(context).maybePop());
  }

  void _openVehicleMap(BuildContext context, String vehicleId) {
    final onVehicleSelected = this.onVehicleSelected;
    if (onVehicleSelected != null) {
      onVehicleSelected(vehicleId);
      return;
    }

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (context) => VehicleMapBloc(
              context.read<GetVehiclePositionForVehicleUseCase>(),
            )..add(VehicleMapStarted(vehicleId)),
            child: VehicleMapScreen(vehicleId: vehicleId),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) {
    final completion = Completer<void>();
    context.read<DeparturesBloc>().add(
      DeparturesRefreshed(completion: completion),
    );

    return completion.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.t.departures.backToStops,
          onPressed: () => _backToStops(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.t.departures.title),
      ),
      body: SafeArea(
        child: BlocBuilder<DeparturesBloc, DeparturesState>(
          builder: (context, state) => _DeparturesBoard(
            stop: stop,
            state: state,
            onRefresh: () => _refresh(context),
            onOpenVehicleMap: (vehicleId) =>
                _openVehicleMap(context, vehicleId),
          ),
        ),
      ),
    );
  }
}

class _DeparturesBoard extends StatelessWidget {
  const _DeparturesBoard({
    required this.stop,
    required this.state,
    required this.onRefresh,
    required this.onOpenVehicleMap,
  });

  final StopGroup stop;
  final DeparturesState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectedStopHeader(stop: stop, lineType: state.representativeLineType),
        if (state.status != DeparturesStatus.loading &&
            state.status != DeparturesStatus.error)
          _TransportFilterRow(state: state),
        if (state.lastUpdated != null || state.isRefreshing)
          _LastUpdatedRow(state: state),
        Expanded(
          child: state.status == DeparturesStatus.loading
              ? LoadingStateView(message: context.t.departures.loading)
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: _RefreshableDeparturesContent(
                    state: state,
                    onOpenVehicleMap: onOpenVehicleMap,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SelectedStopHeader extends StatelessWidget {
  const _SelectedStopHeader({required this.stop, required this.lineType});

  final StopGroup stop;
  final PidLineType lineType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: PidTransportIcon(lineType: lineType),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stop.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransportFilterRow extends StatelessWidget {
  const _TransportFilterRow({required this.state});

  static const _allFilterValue = 'all';

  final DeparturesState state;

  @override
  Widget build(BuildContext context) {
    final selectedMode = state.selectedTransportMode;
    final modes = state.availableTransportModes;
    final filters = [
      PidFilterChipData(
        value: _allFilterValue,
        label: context.t.departures.filterAll,
      ),
      for (final mode in modes)
        PidFilterChipData(
          value: mode.name,
          label: _transportModeLabel(context, mode),
          icon: _transportModeIcon(mode),
        ),
    ];

    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PidFilterChips(
            filters: filters,
            selectedValue: selectedMode?.name ?? _allFilterValue,
            onSelected: (value) {
              context.read<DeparturesBloc>().add(
                DeparturesTransportFilterSelected(
                  value == _allFilterValue
                      ? null
                      : _transportModeFromValue(value, modes),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

PidTransportMode? _transportModeFromValue(
  String value,
  List<PidTransportMode> modes,
) {
  for (final mode in modes) {
    if (mode.name == value) {
      return mode;
    }
  }

  return null;
}

IconData _transportModeIcon(PidTransportMode mode) {
  return switch (mode) {
    PidTransportMode.metro => Icons.directions_subway_rounded,
    PidTransportMode.tram => Icons.tram_rounded,
    PidTransportMode.bus => Icons.directions_bus_rounded,
    PidTransportMode.trolleybus => Icons.electric_rickshaw_rounded,
    PidTransportMode.train => Icons.train_rounded,
    PidTransportMode.ferry => Icons.directions_boat_rounded,
    PidTransportMode.funicular => Icons.cable_rounded,
    PidTransportMode.unknown => Icons.more_horiz_rounded,
  };
}

class _LastUpdatedRow extends StatelessWidget {
  const _LastUpdatedRow({required this.state});

  final DeparturesState state;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = state.lastUpdated;
    final seconds = lastUpdated == null ? 0 : elapsedSecondsSince(lastUpdated);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: state.isRefreshing
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Text(
            context.t.departures.lastUpdatedAgo(seconds: seconds),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshableDeparturesContent extends StatelessWidget {
  const _RefreshableDeparturesContent({
    required this.state,
    required this.onOpenVehicleMap,
  });

  final DeparturesState state;
  final ValueChanged<String> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    if (state.status == DeparturesStatus.error) {
      final strings = context.t;

      return CenteredScrollView(
        child: ErrorStateView(
          message: userMessageForAppError(
            state.error,
            fallbackMessage: strings.departures.loadFailed,
            invalidDataMessage: strings.departures.invalidData,
          ),
          onRetry: () {
            context.read<DeparturesBloc>().add(const DeparturesRetried());
          },
        ),
      );
    }

    final visibleDepartures = state.visibleDepartures;
    if (state.status == DeparturesStatus.empty || visibleDepartures.isEmpty) {
      return CenteredScrollView(
        child: EmptyStateView(
          message: state.selectedTransportMode == null
              ? context.t.departures.empty
              : context.t.departures.emptyFilter,
          icon: Icons.departure_board_outlined,
        ),
      );
    }

    return _DeparturesList(
      state: state,
      departures: visibleDepartures,
      onOpenVehicleMap: onOpenVehicleMap,
    );
  }
}

class _DeparturesList extends StatelessWidget {
  const _DeparturesList({
    required this.state,
    required this.departures,
    required this.onOpenVehicleMap,
  });

  final DeparturesState state;
  final List<Departure> departures;
  final ValueChanged<String> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    final headerCount = state.refreshError != null ? 1 : 0;
    final itemCount = departures.length + headerCount;

    return ListView.separated(
      key: const ValueKey('departures-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (state.refreshError != null && index == 0) {
          return _RefreshWarning(error: state.refreshError);
        }

        final departure = departures[index - headerCount];
        // Departure boards can omit vehicle.id. A separate lookup would be
        // needed; do not fake vehicle tracking from gtfsTripId.

        return DepartureTile(
          departure: departure,
          onOpenVehicleMap: departure.vehicleId == null
              ? null
              : () => onOpenVehicleMap(departure.vehicleId!),
        );
      },
    );
  }
}

String _transportModeLabel(BuildContext context, PidTransportMode mode) {
  final strings = context.t.departures;

  return switch (mode) {
    PidTransportMode.metro => strings.filterMetro,
    PidTransportMode.tram => strings.filterTram,
    PidTransportMode.bus => strings.filterBus,
    PidTransportMode.trolleybus => strings.filterTrolleybus,
    PidTransportMode.train => strings.filterTrain,
    PidTransportMode.ferry => strings.filterFerry,
    PidTransportMode.funicular => strings.filterFunicular,
    PidTransportMode.unknown => strings.filterOther,
  };
}

class _RefreshWarning extends StatelessWidget {
  const _RefreshWarning({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final message = userMessageForAppError(
      error,
      fallbackMessage: context.t.errors.refreshFailed,
    );
    final strings = context.t;

    return PidStatusBanner(
      tone: PidStatusBannerTone.error,
      icon: Icons.info_outline,
      title: strings.departures.staleWarning,
      message: message,
    );
  }
}
