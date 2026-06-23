import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../../departures/presentation/departures_screen.dart';
import '../domain/stop.dart';
import 'cubit/stops_cubit.dart';
import 'cubit/stops_state.dart';

class StopsScreen extends StatefulWidget {
  const StopsScreen({super.key, this.onStopSelected});

  final ValueChanged<Stop>? onStopSelected;

  @override
  State<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends State<StopsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final cubit = context.read<StopsCubit>();
    if (_searchController.text != cubit.state.searchQuery) {
      cubit.searchChanged(_searchController.text);
    }
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

    return BlocListener<StopsCubit, StopsState>(
      listenWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery &&
          _searchController.text != current.searchQuery,
      listener: (_, state) {
        _searchController.value = TextEditingValue(
          text: state.searchQuery,
          selection: TextSelection.collapsed(offset: state.searchQuery.length),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: Text(strings.stops.title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                BlocSelector<StopsCubit, StopsState, bool>(
                  selector: (state) =>
                      state.status != StopsStatus.loading &&
                      state.status != StopsStatus.error,
                  builder: (context, enabled) {
                    return PidSearchField(
                      controller: _searchController,
                      enabled: enabled,
                      hintText: strings.stops.searchHint,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<StopsCubit, StopsState>(
                    builder: (context, state) => _buildContent(context, state),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StopsState state) {
    final strings = context.t;

    return switch (state.status) {
      StopsStatus.loading => LoadingStateView(message: strings.stops.loading),
      StopsStatus.error => ErrorStateView(
        message: userMessageForAppError(
          state.error,
          fallbackMessage: strings.stops.loadFailed,
          invalidDataMessage: strings.stops.invalidData,
        ),
        onRetry: context.read<StopsCubit>().retry,
      ),
      StopsStatus.empty => EmptyStateView(
        message: state.isSearchActive
            ? strings.stops.emptySearch
            : strings.stops.empty,
        icon: Icons.location_off_outlined,
      ),
      StopsStatus.loaded => _StopsList(
        stops: state.filteredStops,
        onOpenDepartures: _openDepartures,
      ),
    };
  }
}

class _StopsList extends StatelessWidget {
  const _StopsList({required this.stops, required this.onOpenDepartures});

  final List<Stop> stops;
  final ValueChanged<Stop> onOpenDepartures;

  @override
  Widget build(BuildContext context) {
    final strings = context.t;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: stops.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final stop = stops[index];

        return PidStopCard(
          stop: stop.toPidStopData(strings),
          semanticLabel: strings.stops.stopSemantic(name: stop.name),
          onTap: () => onOpenDepartures(stop),
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
