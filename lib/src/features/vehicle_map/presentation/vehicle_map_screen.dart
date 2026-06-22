import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/golemio_api_client.dart';
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
          _warning = _errorMessage(error);
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
      return const Center(child: CircularProgressIndicator());
    }

    final position = _position;
    if (position == null) {
      final error = _error;
      if (error is AppException && error.type == AppExceptionType.invalidData) {
        return _NoPositionState(onRetry: _retry);
      }

      return _ErrorState(message: _errorMessage(error), onRetry: _retry);
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

  String _errorMessage(Object? error) {
    if (error is AppException) {
      return switch (error.type) {
        AppExceptionType.missingToken =>
          'Chybi Golemio API token. Spustte aplikaci s GOLEMIO_API_TOKEN.',
        AppExceptionType.unauthorized =>
          'Golemio API token je neplatny nebo nema opravneni.',
        AppExceptionType.network => 'Nepodarilo se pripojit ke Golemio API.',
        AppExceptionType.timeout => 'Pozadavek na Golemio API vyprsel.',
        AppExceptionType.invalidData =>
          'Poloha vozidla neni momentalne dostupna.',
        AppExceptionType.emptyResponse || AppExceptionType.invalidJson =>
          'Golemio API vratilo polohu, kterou se nepodarilo nacist.',
        AppExceptionType.badRequest ||
        AppExceptionType.notFound ||
        AppExceptionType.server ||
        AppExceptionType.unexpectedStatus =>
          'Golemio API vratilo chybu. Zkuste to prosim znovu.',
      };
    }

    return 'Polohu vozidla se nepodarilo nacist. Zkuste to prosim znovu.';
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
            Text('Posledni aktualizace ${_formatDateTime(lastUpdated)}'),
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

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    final second = localTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
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

class _NoPositionState extends StatelessWidget {
  const _NoPositionState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.location_off_outlined,
      message: 'Aktualni poloha vozidla neni dostupna.',
      onRetry: onRetry,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.error_outline,
      message: message,
      onRetry: onRetry,
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Zkusit znovu'),
            ),
          ],
        ),
      ),
    );
  }
}
