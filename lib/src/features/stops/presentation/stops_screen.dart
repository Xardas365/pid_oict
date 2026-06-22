import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/golemio_api_client.dart';
import '../../departures/presentation/departures_placeholder_screen.dart';
import '../data/stops_repository.dart';
import '../domain/stop.dart';
import 'stop_filter.dart';
import 'widgets/stop_list_tile.dart';

class StopsScreen extends StatefulWidget {
  const StopsScreen({super.key, this.loadStops});

  final Future<List<Stop>> Function()? loadStops;

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
    final repository = StopsRepository(apiClient);

    return repository.fetchStops().whenComplete(apiClient.close);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _openDepartures(Stop stop) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeparturesPlaceholderScreen(stop: stop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PID zastavky')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                enabled: !_isLoading && _error == null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Hledat podle nazvu zastavky',
                  labelText: 'Vyhledat zastavku',
                  prefixIcon: Icon(Icons.search),
                ),
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
    if (_isLoading) {
      return const _LoadingState();
    }

    final error = _error;
    if (error != null) {
      return _ErrorState(message: _errorMessage(error), onRetry: _loadStops);
    }

    final filteredStops = _filteredStops;
    if (filteredStops.isEmpty) {
      return _EmptyState(
        message: _searchController.text.trim().isEmpty
            ? 'Nebyly nalezeny zadne zastavky.'
            : 'Zadne zastavky neodpovidaji hledani.',
      );
    }

    return ListView.separated(
      itemCount: filteredStops.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final stop = filteredStops[index];

        return StopListTile(stop: stop, onTap: () => _openDepartures(stop));
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
          'Golemio API vratilo data, ktera se nepodarilo nacist.',
        AppExceptionType.badRequest ||
        AppExceptionType.notFound ||
        AppExceptionType.server ||
        AppExceptionType.unexpectedStatus =>
          'Golemio API vratilo chybu. Zkuste to prosim znovu.',
      };
    }

    return 'Zastavky se nepodarilo nacist. Zkuste to prosim znovu.';
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, textAlign: TextAlign.center));
  }
}
