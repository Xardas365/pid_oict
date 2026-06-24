import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../i18n/strings.g.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/centered_scroll_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../../stops/domain/stop_group.dart';
import '../../vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../../vehicle_map/presentation/vehicle_map_screen.dart';
import 'bloc/departures_bloc.dart';
import 'bloc/departures_event.dart';
import 'bloc/departures_state.dart';
import 'widgets/departure_tile.dart';

class DeparturesScreen extends StatelessWidget {
  const DeparturesScreen({
    required this.stop,
    super.key,
    this.onVehicleSelected,
  });

  final StopGroup stop;
  final ValueChanged<String>? onVehicleSelected;

  void _openVehicleMap(BuildContext context, String vehicleId) {
    final onVehicleSelected = this.onVehicleSelected;
    if (onVehicleSelected != null) {
      onVehicleSelected(vehicleId);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (context) => VehicleMapBloc(
            context.read<GetVehiclePositionForVehicleUseCase>(),
          )..add(VehicleMapStarted(vehicleId)),
          child: VehicleMapScreen(vehicleId: vehicleId),
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
      appBar: AppBar(title: Text(stop.name)),
      body: SafeArea(
        child: BlocBuilder<DeparturesBloc, DeparturesState>(
          builder: (context, state) {
            if (state.status == DeparturesStatus.loading) {
              return LoadingStateView(message: context.t.departures.loading);
            }

            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: _buildRefreshableContent(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRefreshableContent(BuildContext context, DeparturesState state) {
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

    if (state.status == DeparturesStatus.empty) {
      return CenteredScrollView(
        child: EmptyStateView(
          message: context.t.departures.empty,
          icon: Icons.departure_board_outlined,
        ),
      );
    }

    return _DeparturesList(
      state: state,
      onOpenVehicleMap: (vehicleId) => _openVehicleMap(context, vehicleId),
    );
  }
}

class _DeparturesList extends StatelessWidget {
  const _DeparturesList({required this.state, required this.onOpenVehicleMap});

  final DeparturesState state;
  final ValueChanged<String> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    final headerCount =
        (state.isRefreshing ? 1 : 0) + (state.refreshError != null ? 1 : 0);
    final itemCount = state.departures.length + headerCount;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (state.isRefreshing && index == 0) {
          return Semantics(
            label: context.t.departures.refreshing,
            child: const LinearProgressIndicator(),
          );
        }

        final warningIndex = state.isRefreshing ? 1 : 0;
        if (state.refreshError != null && index == warningIndex) {
          return _RefreshWarning(error: state.refreshError);
        }

        final departure = state.departures[index - headerCount];
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.departures.staleWarning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
