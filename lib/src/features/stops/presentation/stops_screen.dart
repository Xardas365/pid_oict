import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_state_view.dart';
import '../../departures/domain/usecases/load_departure_board_use_case.dart';
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
  static const _backToTopOffset = 240.0;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  var _showBackToTopButton = false;

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
    _updateBackToTopButton(position);

    final remainingExtent = position.maxScrollExtent - position.pixels;
    if (remainingExtent < 480) {
      unawaited(context.read<StopsCubit>().loadMore());
    }
  }

  void _updateBackToTopButton(ScrollPosition position) {
    if (!mounted) {
      return;
    }

    final showBackToTopButton =
        position.maxScrollExtent > 0 && position.pixels > _backToTopOffset;

    if (showBackToTopButton == _showBackToTopButton) {
      return;
    }

    setState(() {
      _showBackToTopButton = showBackToTopButton;
    });
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    unawaited(
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _openDepartures(StopGroup stop) {
    unawaited(context.read<StopsCubit>().recordRecentStop(stop));

    final onStopSelected = widget.onStopSelected;
    if (onStopSelected != null) {
      onStopSelected(stop);
      return;
    }

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (context) => DeparturesBloc(
              context.read<LoadDepartureBoardUseCase>(),
            )..add(DeparturesStarted(stop)),
            child: DeparturesScreen(stop: stop),
          ),
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
      child: PidStopsTemplate.screen(
        title: strings.stops.title,
        search: BlocSelector<StopsCubit, StopsState, bool>(
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
        searchProgress: BlocSelector<StopsCubit, StopsState, bool>(
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
        statusBanner:
            BlocSelector<StopsCubit, StopsState, _StopsCacheBannerData?>(
              selector: _cacheBannerData,
              builder: (context, banner) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: banner == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: PidStatusBanner(
                          message: banner.message,
                          tone: banner.tone,
                          icon: banner.tone == PidStatusBannerTone.warning
                              ? Icons.warning_amber_rounded
                              : Icons.save_outlined,
                        ),
                      ),
              ),
            ),
        content: BlocBuilder<StopsCubit, StopsState>(
          builder: _buildContent,
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
        state: state,
        isLoadingMore: state.isLoadingMore,
        showBackToTopButton: _showBackToTopButton,
        controller: _scrollController,
        onOpenDepartures: _openDepartures,
        onScrollToTop: _scrollToTop,
        onToggleFavorite: (stop) {
          unawaited(context.read<StopsCubit>().toggleFavorite(stop));
        },
      ),
    };
  }

  _StopsCacheBannerData? _cacheBannerData(StopsState state) {
    if (state.status == StopsStatus.loading ||
        state.status == StopsStatus.error ||
        !state.isFromCache) {
      return null;
    }

    final strings = context.t;
    if (state.cacheRefreshError != null) {
      return _StopsCacheBannerData(
        message: strings.stops.savedStopsRefreshFailed,
        tone: PidStatusBannerTone.warning,
      );
    }

    if (state.isCacheStale) {
      return _StopsCacheBannerData(
        message: strings.stops.showingOlderSavedStops,
        tone: PidStatusBannerTone.warning,
      );
    }

    return _StopsCacheBannerData(
      message: strings.stops.showingSavedStops,
      tone: PidStatusBannerTone.info,
    );
  }
}

class _StopsCacheBannerData {
  const _StopsCacheBannerData({required this.message, required this.tone});

  final String message;
  final PidStatusBannerTone tone;
}

class _StopsList extends StatelessWidget {
  const _StopsList({
    required this.state,
    required this.isLoadingMore,
    required this.showBackToTopButton,
    required this.controller,
    required this.onOpenDepartures,
    required this.onScrollToTop,
    required this.onToggleFavorite,
  });

  final StopsState state;
  final bool isLoadingMore;
  final bool showBackToTopButton;
  final ScrollController controller;
  final ValueChanged<StopGroup> onOpenDepartures;
  final VoidCallback onScrollToTop;
  final ValueChanged<StopGroup> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final strings = context.t;
    final isSearchActive = state.isSearchActive;
    final favoriteGroups = isSearchActive
        ? const <StopGroup>[]
        : state.favoriteGroups;
    final favoriteGroupIds = favoriteGroups.map((group) => group.id).toSet();
    final recentGroupCandidates = isSearchActive
        ? const <StopGroup>[]
        : state.recentGroups
              .where((group) => !favoriteGroupIds.contains(group.id))
              .toList(growable: false);
    final candidatePinnedGroupIds = <String>{
      for (final group in favoriteGroups) group.id,
      for (final group in recentGroupCandidates) group.id,
    };
    final mainGroupsWithCandidatePinned = isSearchActive
        ? state.filteredGroups
        : state.filteredGroups
              .where((group) => !candidatePinnedGroupIds.contains(group.id))
              .toList(growable: false);
    final recentGroups =
        recentGroupCandidates.isNotEmpty &&
            (favoriteGroups.isNotEmpty ||
                mainGroupsWithCandidatePinned.isNotEmpty)
        ? recentGroupCandidates
        : const <StopGroup>[];
    final pinnedGroupIds = <String>{
      for (final group in favoriteGroups) group.id,
      for (final group in recentGroups) group.id,
    };
    final mainGroups = isSearchActive
        ? state.filteredGroups
        : state.filteredGroups
              .where((group) => !pinnedGroupIds.contains(group.id))
              .toList(growable: false);

    return PidSectionedStopList(
      controller: controller,
      isLoadingMore: isLoadingMore,
      showBackToTopButton: showBackToTopButton,
      backToTopTooltip: strings.stops.backToTop,
      onScrollToTop: onScrollToTop,
      sections: [
        if (favoriteGroups.isNotEmpty)
          PidStopListSection(
            title: strings.stops.favoriteStops,
            items: _stopItems(context, favoriteGroups),
          ),
        if (recentGroups.isNotEmpty)
          PidStopListSection(
            title: strings.stops.recentStops,
            topPadding: favoriteGroups.isEmpty ? 0 : 14,
            items: _stopItems(context, recentGroups),
          ),
        PidStopListSection(items: _stopItems(context, mainGroups)),
      ],
    );
  }

  List<PidStopListItem> _stopItems(
    BuildContext context,
    List<StopGroup> groups,
  ) {
    final strings = context.t;

    return [
      for (final stop in groups)
        PidStopListItem(
          stop: stop
              .toPidStopData(strings)
              .copyWith(isHighlighted: state.isFavorite(stop)),
          semanticLabel: strings.stops.stopSemantic(name: stop.name),
          onTap: () => onOpenDepartures(stop),
          trailingAction: _favoriteAction(context, stop),
        ),
    ];
  }

  PidStopCardAction _favoriteAction(BuildContext context, StopGroup stop) {
    final strings = context.t;
    final isFavorite = state.isFavorite(stop);
    final favoriteLabel = isFavorite
        ? strings.stops.removeFavorite
        : strings.stops.addFavorite;

    return PidStopCardAction(
      tooltip: favoriteLabel,
      onPressed: () => onToggleFavorite(stop),
      icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
      color: isFavorite ? PidSeedColors.primary : PidSeedColors.textMuted,
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
    final hasManyPlatforms = platformCodes.length > 3;

    if (hasManyPlatforms && zone != null && zone.isNotEmpty) {
      return strings.stops.platformCountWithZone(
        count: platformCodes.length,
        zone: zone,
      );
    }

    if (hasManyPlatforms) {
      return strings.stops.platformCount(count: platformCodes.length);
    }

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
