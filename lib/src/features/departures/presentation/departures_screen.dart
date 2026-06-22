import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/golemio_api_client.dart';
import '../../stops/domain/stop.dart';
import '../../vehicle_map/presentation/vehicle_map_screen.dart';
import '../data/departures_repository.dart';
import '../domain/departure.dart';
import 'widgets/departure_tile.dart';

class DeparturesScreen extends StatefulWidget {
  const DeparturesScreen({required this.stop, super.key, this.loadDepartures});

  final Stop stop;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;

  @override
  State<DeparturesScreen> createState() => _DeparturesScreenState();
}

class _DeparturesScreenState extends State<DeparturesScreen> {
  var _departures = <Departure>[];
  Object? _error;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartures();
  }

  Future<void> _loadDepartures({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final departures = await _defaultLoadDepartures();
      if (!mounted) {
        return;
      }

      setState(() {
        _departures = departures;
        _error = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _departures = <Departure>[];
        _error = error;
        _isLoading = false;
      });
    }
  }

  Future<List<Departure>> _defaultLoadDepartures() {
    final loadDepartures = widget.loadDepartures;
    if (loadDepartures != null) {
      return loadDepartures(widget.stop);
    }

    final apiClient = GolemioApiClient();
    final repository = DeparturesRepository(apiClient);

    return repository
        .fetchDeparturesForStop(widget.stop)
        .whenComplete(apiClient.close);
  }

  void _openVehicleMap(String vehicleId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleMapScreen(vehicleId: vehicleId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stop.name)),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _loadDepartures(showLoading: false),
      child: _buildRefreshableContent(),
    );
  }

  Widget _buildRefreshableContent() {
    final error = _error;
    if (error != null) {
      return _CenteredRefreshable(
        child: _ErrorState(
          message: _errorMessage(error),
          onRetry: _loadDepartures,
        ),
      );
    }

    if (_departures.isEmpty) {
      return const _CenteredRefreshable(child: _EmptyState());
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _departures.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final departure = _departures[index];

        return DepartureTile(
          departure: departure,
          onOpenVehicleMap: departure.vehicleId == null
              ? null
              : () => _openVehicleMap(departure.vehicleId!),
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return switch (error.type) {
        AppExceptionType.missingToken =>
          'Chybi Golemio API token. Spustte aplikaci s GOLEMIO_API_TOKEN.',
        AppExceptionType.unauthorized =>
          'Golemio API token je neplatny nebo nema opravneni.',
        AppExceptionType.network => 'Nepodarilo se pripojit ke Golemio API.',
        AppExceptionType.timeout => 'Pozadavek na Golemio API vyprsel.',
        AppExceptionType.emptyResponse ||
        AppExceptionType.invalidJson ||
        AppExceptionType.invalidData =>
          'Golemio API vratilo odjezdy, ktere se nepodarilo nacist.',
        AppExceptionType.badRequest ||
        AppExceptionType.notFound ||
        AppExceptionType.server ||
        AppExceptionType.unexpectedStatus =>
          'Golemio API vratilo chybu. Zkuste to prosim znovu.',
      };
    }

    return 'Odjezdy se nepodarilo nacist. Zkuste to prosim znovu.';
  }
}

class _CenteredRefreshable extends StatelessWidget {
  const _CenteredRefreshable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(padding: const EdgeInsets.all(24), child: child),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 40),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Zkusit znovu'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pro tuto zastavku nebyly nalezeny zadne odjezdy.',
      textAlign: TextAlign.center,
    );
  }
}
