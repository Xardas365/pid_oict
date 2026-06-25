import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/utils/date_time_formatters.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../domain/vehicle_position.dart';
import 'bloc/vehicle_map_bloc.dart';
import 'bloc/vehicle_map_event.dart';
import 'bloc/vehicle_map_state.dart';
import 'vehicle_map_args.dart';

class VehicleMapScreen extends StatelessWidget {
  const VehicleMapScreen({
    required this.args,
    super.key,
    this.showMapTiles = true,
  });

  final VehicleMapArgs args;
  final bool showMapTiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.vehicleMap.title)),
      body: SafeArea(
        child: BlocBuilder<VehicleMapBloc, VehicleMapState>(
          builder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, VehicleMapState state) {
    if (state.status == VehicleMapStatus.loading && state.position == null) {
      return LoadingStateView(message: context.t.vehicleMap.loading);
    }

    final position = state.position;
    if (position == null) {
      final strings = context.t;
      if (state.status == VehicleMapStatus.error) {
        return ErrorStateView(
          message: userMessageForAppError(
            state.error,
            fallbackMessage: strings.vehicleMap.loadFailed,
          ),
          onRetry: () {
            context.read<VehicleMapBloc>().add(const VehicleMapRetried());
          },
        );
      }

      return EmptyStateView(
        message: userMessageForAppError(
          state.error,
          fallbackMessage: strings.vehicleMap.loadFailed,
          invalidDataMessage: strings.vehicleMap.invalidData,
        ),
        icon: Icons.location_off_outlined,
        onRetry: () {
          context.read<VehicleMapBloc>().add(const VehicleMapRetried());
        },
      );
    }

    return _MapState(
      position: position,
      staleError: state.staleError,
      isRefreshing: state.isRefreshing,
      showMapTiles: showMapTiles,
    );
  }
}

class _MapState extends StatelessWidget {
  const _MapState({
    required this.position,
    required this.staleError,
    required this.isRefreshing,
    required this.showMapTiles,
  });

  final VehiclePosition position;
  final AppFailure? staleError;
  final bool isRefreshing;
  final bool showMapTiles;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(position.latitude, position.longitude);

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(initialCenter: point, initialZoom: 15),
            children: [
              if (showMapTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'pid_oict',
                )
              else
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFE7EEF4)),
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: _MapAttribution(),
              ),
            ],
          ),
        ),
        if (isRefreshing) const LinearProgressIndicator(),
        _VehiclePositionStatus(position: position, staleError: staleError),
      ],
    );
  }
}

class _VehiclePositionStatus extends StatelessWidget {
  const _VehiclePositionStatus({
    required this.position,
    required this.staleError,
  });

  final VehiclePosition position;
  final AppFailure? staleError;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = position.lastUpdated;
    final staleError = this.staleError;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t.vehicleMap.vehicleLabel(vehicleId: position.vehicleId),
          ),
          if (lastUpdated != null)
            Text(
              context.t.vehicleMap.lastUpdated(
                time: formatClockTimeWithSeconds(lastUpdated),
              ),
            ),
          if (staleError != null) ...[
            const SizedBox(height: 8),
            Text(
              staleDataWarning(staleError),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          context.t.vehicleMap.attribution,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
