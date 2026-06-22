import 'package:flutter/material.dart';

import '../../../core/network/golemio_api_client.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/centered_scroll_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
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
      return const LoadingStateView(message: 'Nacitani odjezdu...');
    }

    return RefreshIndicator(
      onRefresh: () => _loadDepartures(showLoading: false),
      child: _buildRefreshableContent(),
    );
  }

  Widget _buildRefreshableContent() {
    final error = _error;
    if (error != null) {
      return CenteredScrollView(
        child: ErrorStateView(
          message: userMessageForAppError(
            error,
            fallbackMessage:
                'Odjezdy se nepodarilo nacist. Zkuste to prosim znovu.',
            invalidDataMessage:
                'Golemio API nevratilo zadne pouzitelne odjezdy.',
          ),
          onRetry: _loadDepartures,
        ),
      );
    }

    if (_departures.isEmpty) {
      return const CenteredScrollView(
        child: EmptyStateView(
          message: 'Pro tuto zastavku nejsou dostupne zadne odjezdy.',
          icon: Icons.departure_board_outlined,
        ),
      );
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
}
