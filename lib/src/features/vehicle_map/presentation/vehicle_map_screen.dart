import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/golemio_api_client.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/utils/date_time_formatters.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../data/vehicle_position_repository.dart';
import '../domain/vehicle_position.dart';

class VehicleMapScreen extends StatefulWidget {
  const VehicleMapScreen({
    required this.vehicleId,
    super.key,
    this.loadVehiclePosition,
    this.refreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final String vehicleId;
  final Future<VehiclePosition> Function(String vehicleId)? loadVehiclePosition;
  final Duration refreshInterval;
  final bool showMapTiles;

  @override
  State<VehicleMapScreen> createState() => _VehicleMapScreenState();
}

class _VehicleMapScreenState extends State<VehicleMapScreen> {
  VehiclePosition? _position;
  Object? _error;
  String? _warning;
  var _isLoading = true;
  var _isRequestInFlight = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPosition(showInitialLoading: true);
    _startPolling();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    if (widget.refreshInterval <= Duration.zero) {
      return;
    }

    _refreshTimer = Timer.periodic(
      widget.refreshInterval,
      (_) => _loadPosition(showInitialLoading: false),
    );
  }

  Future<void> _loadPosition({required bool showInitialLoading}) async {
    if (_isRequestInFlight) {
      return;
    }

    _isRequestInFlight = true;
    if (showInitialLoading && _position == null) {
      setState(() {
        _isLoading = true;
        _error = null;
        _warning = null;
      });
    }

    try {
      final position = await _defaultLoadVehiclePosition();
      if (!mounted) {
        return;
      }

      setState(() {
        _position = position;
        _error = null;
        _warning = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (_position == null) {
          _error = error;
          _isLoading = false;
        } else {
          _warning = staleDataWarning(error);
        }
      });
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<VehiclePosition> _defaultLoadVehiclePosition() {
    final loadVehiclePosition = widget.loadVehiclePosition;
    if (loadVehiclePosition != null) {
      return loadVehiclePosition(widget.vehicleId);
    }

    final apiClient = GolemioApiClient();
    final repository = VehiclePositionRepository(apiClient);

    return repository
        .fetchVehiclePosition(widget.vehicleId)
        .whenComplete(apiClient.close);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poloha vozidla')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _position == null) {
      return const LoadingStateView(message: 'Nacitani polohy vozidla...');
    }

    final position = _position;
    if (position == null) {
      final error = _error;
      if (error != null && !_isNoPositionError(error)) {
        return ErrorStateView(
          message: userMessageForAppError(
            error,
            fallbackMessage:
                'Polohu vozidla se nepodarilo nacist. Zkuste to prosim znovu.',
          ),
          onRetry: _retry,
        );
      }

      return EmptyStateView(
        message: userMessageForAppError(
          error,
          fallbackMessage:
              'Polohu vozidla se nepodarilo nacist. Zkuste to prosim znovu.',
          invalidDataMessage: 'Aktualni poloha vozidla neni dostupna.',
        ),
        icon: Icons.location_off_outlined,
        onRetry: _retry,
      );
    }

    return _MapState(
      position: position,
      warning: _warning,
      showMapTiles: widget.showMapTiles,
    );
  }

  void _retry() {
    _loadPosition(showInitialLoading: true);
  }

  bool _isNoPositionError(Object error) {
    return error is AppException && error.type == AppExceptionType.invalidData;
  }
}

class _MapState extends StatelessWidget {
  const _MapState({
    required this.position,
    required this.warning,
    required this.showMapTiles,
  });

  final VehiclePosition position;
  final String? warning;
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
        _VehiclePositionStatus(position: position, warning: warning),
      ],
    );
  }
}

class _VehiclePositionStatus extends StatelessWidget {
  const _VehiclePositionStatus({required this.position, required this.warning});

  final VehiclePosition position;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = position.lastUpdated;
    final warning = this.warning;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Vozidlo ${position.vehicleId}'),
          if (lastUpdated != null)
            Text(
              'Posledni aktualizace ${formatClockTimeWithSeconds(lastUpdated)}',
            ),
          if (warning != null) ...[
            const SizedBox(height: 8),
            Text(
              warning,
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
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Text(
          'Map data (c) OpenStreetMap contributors',
          style: TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
