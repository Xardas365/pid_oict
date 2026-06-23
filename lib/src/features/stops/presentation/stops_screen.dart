import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../../departures/domain/usecases/get_departures_for_stop_use_case.dart';
import '../../departures/presentation/bloc/departures_bloc.dart';
import '../../departures/presentation/bloc/departures_event.dart';
import '../../departures/presentation/departures_screen.dart';
import '../domain/stop_group.dart';
import 'cubit/stops_cubit.dart';
import 'cubit/stops_state.dart';

class StopsScreen extends StatefulWidget {
  const StopsScreen({super.key, this.onStopSelected});

  final ValueChanged<StopGroup>? onStopSelected;

  @override
  State<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends State<StopsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final cubit = context.read<StopsCubit>();
    if (_searchController.text != cubit.state.searchQuery) {
      cubit.searchChanged(_searchController.text);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final remainingExtent = position.maxScrollExtent - position.pixels;
    if (remainingExtent < 480) {
      context.read<StopsCubit>().loadMore();
    }
  }

  void _openDepartures(StopGroup stop) {
    final onStopSelected = widget.onStopSelected;
    if (onStopSelected != null) {
      onStopSelected(stop);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (context) =>
              DeparturesBloc(context.read<GetDeparturesForStopUseCase>())
                ..add(DeparturesStarted(stop)),
          child: DeparturesScreen(stop: stop),
        ),
      ),
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
                BlocSelector<StopsCubit, StopsState, bool>(
                  selector: (state) => state.isSearching,
                  builder: (context, isSearching) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: isSearching
                        ? const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(minHeight: 2),
                          )
                        : const SizedBox.shrink(),
                  ),
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
        stops: state.filteredGroups,
        isLoadingMore: state.isLoadingMore,
        controller: _scrollController,
        onOpenDepartures: _openDepartures,
      ),
    };
  }
}

class _StopsList extends StatelessWidget {
  const _StopsList({
    required this.stops,
    required this.isLoadingMore,
    required this.controller,
    required this.onOpenDepartures,
  });

  final List<StopGroup> stops;
  final bool isLoadingMore;
  final ScrollController controller;
  final ValueChanged<StopGroup> onOpenDepartures;

  @override
  Widget build(BuildContext context) {
    final strings = context.t;

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: stops.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= stops.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

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

extension on StopGroup {
  PidStopData toPidStopData(Translations strings) {
    return PidStopData(id: id, name: name, subtitle: _subtitle(strings));
  }

  String _subtitle(Translations strings) {
    final platforms = platformCodes.join(', ');
    final zone = zoneId?.trim();

    if (platforms.isNotEmpty && zone != null && zone.isNotEmpty) {
      return strings.stops.platformsWithZone(platforms: platforms, zone: zone);
    }

    if (platforms.isNotEmpty) {
      return strings.stops.platforms(platforms: platforms);
    }

    if (zone != null && zone.isNotEmpty) {
      return strings.stops.stopPointsWithZone(count: stopCount, zone: zone);
    }

    return strings.stops.stopPoints(count: stopCount);
  }
}
