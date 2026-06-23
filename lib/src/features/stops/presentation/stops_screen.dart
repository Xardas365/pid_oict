import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/network/golemio_api_client.dart';
import '../../departures/presentation/departures_screen.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../data/repositories/golemio_stops_repository.dart';
import '../domain/stop.dart';
import 'stop_filter.dart';

class StopsScreen extends StatefulWidget {
  const StopsScreen({super.key, this.loadStops, this.onStopSelected});

  final Future<List<Stop>> Function()? loadStops;
  final ValueChanged<Stop>? onStopSelected;

  @override
  State<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends State<StopsScreen> {
  final _searchController = TextEditingController();

  var _stops = <Stop>[];
  Object? _error;
  var _isLoading = true;

  List<Stop> get _filteredStops =>
      filterStopsByName(_stops, _searchController.text);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadStops();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stops = await _defaultLoadStops();
      if (!mounted) {
        return;
      }

      setState(() {
        _stops = stops;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _stops = <Stop>[];
        _isLoading = false;
      });
    }
  }

  Future<List<Stop>> _defaultLoadStops() {
    final loadStops = widget.loadStops;
    if (loadStops != null) {
      return loadStops();
    }

    final apiClient = GolemioApiClient();
    final repository = GolemioStopsRepository(apiClient);

    return repository.fetchStops().whenComplete(apiClient.close);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _openDepartures(Stop stop) {
    final onStopSelected = widget.onStopSelected;
    if (onStopSelected != null) {
      onStopSelected(stop);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DeparturesScreen(stop: stop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t;

    return Scaffold(
      appBar: AppBar(title: Text(strings.stops.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              PidSearchField(
                controller: _searchController,
                enabled: !_isLoading && _error == null,
                hintText: strings.stops.searchHint,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final strings = context.t;

    if (_isLoading) {
      return LoadingStateView(message: strings.stops.loading);
    }

    final error = _error;
    if (error != null) {
      return ErrorStateView(
        message: userMessageForAppError(
          error,
          fallbackMessage: strings.stops.loadFailed,
          invalidDataMessage: strings.stops.invalidData,
        ),
        onRetry: _loadStops,
      );
    }

    final filteredStops = _filteredStops;
    if (filteredStops.isEmpty) {
      return EmptyStateView(
        message: _searchController.text.trim().isEmpty
            ? strings.stops.empty
            : strings.stops.emptySearch,
        icon: Icons.location_off_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredStops.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final stop = filteredStops[index];

        return PidStopCard(
          stop: stop.toPidStopData(strings),
          semanticLabel: strings.stops.stopSemantic(name: stop.name),
          onTap: () => _openDepartures(stop),
        );
      },
    );
  }
}

extension on Stop {
  PidStopData toPidStopData(Translations strings) {
    return PidStopData(id: id, name: name, subtitle: _subtitle(strings));
  }

  String _subtitle(Translations strings) {
    final platform = platformCode?.trim();
    if (platform != null && platform.isNotEmpty) {
      return strings.stops.platformWithId(platform: platform, id: id);
    }

    final latitude = this.latitude;
    final longitude = this.longitude;
    if (latitude != null && longitude != null) {
      return strings.stops.coordinatesWithId(
        id: id,
        latitude: latitude.toStringAsFixed(5),
        longitude: longitude.toStringAsFixed(5),
      );
    }

    return strings.stops.stopId(id: id);
  }
}
