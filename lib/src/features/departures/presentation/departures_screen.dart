import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/domain/pid_line_type.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/utils/app_error_messages.dart';
import '../../../shared/widgets/centered_scroll_view.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/live_relative_time_text.dart';
import '../../stops/domain/stop_group.dart';
import '../../vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_bloc.dart';
import '../../vehicle_map/presentation/bloc/vehicle_map_event.dart';
import '../../vehicle_map/presentation/vehicle_map_args.dart';
import '../../vehicle_map/presentation/vehicle_map_screen.dart';
import '../domain/departure.dart';
import 'bloc/departures_bloc.dart';
import 'bloc/departures_event.dart';
import 'bloc/departures_state.dart';
import 'departure_platform_sections.dart';
import 'departure_time_display_mode.dart';
import 'widgets/departure_tile.dart';

const double _departuresContentHorizontalPadding = PidSeedSpacing.lg;
const double _departuresHeaderTopPadding = PidSeedSpacing.sm;
const double _departuresHeaderBottomPadding = PidSeedSpacing.xxs;
const double _departuresFilterHeight = 42;
const double _departuresLastUpdatedTopPadding = PidSeedSpacing.xxs;
const double _departuresLastUpdatedBottomPadding = PidSeedSpacing.sm;
const double _departuresListTopPadding = PidSeedSpacing.sm;
const double _departuresListBottomPadding = PidSeedSpacing.lg;
const double _departuresListGap = PidSeedSpacing.sm;

class DeparturesScreen extends StatelessWidget {
  const DeparturesScreen({
    required this.stop,
    super.key,
    this.onVehicleSelected,
    this.onBackToStops,
  });

  final StopGroup stop;
  final ValueChanged<VehicleMapArgs>? onVehicleSelected;
  final VoidCallback? onBackToStops;

  void _backToStops(BuildContext context) {
    final onBackToStops = this.onBackToStops;
    if (onBackToStops != null) {
      onBackToStops();
      return;
    }

    unawaited(Navigator.of(context).maybePop());
  }

  void _openVehicleMap(BuildContext context, VehicleMapArgs args) {
    final onVehicleSelected = this.onVehicleSelected;
    if (onVehicleSelected != null) {
      onVehicleSelected(args);
      return;
    }

    final getVehiclePosition = context
        .read<GetVehiclePositionForVehicleUseCase>();

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => VehicleMapBloc(
              getVehiclePosition,
            )..add(VehicleMapStarted(args.vehicleId)),
            child: VehicleMapScreen(args: args),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) {
    final completion = Completer<void>();
    context.read<DeparturesBloc>().add(
      DeparturesRefreshed(completion: completion),
    );

    return completion.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeparturesBloc, DeparturesState>(
      builder: (context, state) => _DeparturesBoard(
        stop: stop,
        state: state,
        onBackToStops: () => _backToStops(context),
        onRefresh: () => _refresh(context),
        onOpenVehicleMap: (args) => _openVehicleMap(context, args),
      ),
    );
  }
}

class _DeparturesBoard extends StatelessWidget {
  const _DeparturesBoard({
    required this.stop,
    required this.state,
    required this.onBackToStops,
    required this.onRefresh,
    required this.onOpenVehicleMap,
  });

  final StopGroup stop;
  final DeparturesState state;
  final VoidCallback onBackToStops;
  final Future<void> Function() onRefresh;
  final ValueChanged<VehicleMapArgs> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    final isInitialLoading = state.status == DeparturesStatus.loading;
    final isInitialError = state.status == DeparturesStatus.error;

    return PidDeparturesTemplate.screen(
      title: context.t.departures.title,
      backTooltip: context.t.departures.backToStops,
      onBack: onBackToStops,
      stopHeader: _SelectedStopHeader(stop: stop),
      filterRow: isInitialLoading
          ? const _TransportFilterSkeletonRow()
          : isInitialError
          ? null
          : _TransportFilterRow(state: state),
      lastUpdatedRow: state.lastUpdated != null || state.isRefreshing
          ? _LastUpdatedRow(state: state)
          : null,
      content: isInitialLoading
          ? const _DeparturesLoadingSkeleton()
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: _RefreshableDeparturesContent(
                state: state,
                onOpenVehicleMap: onOpenVehicleMap,
              ),
            ),
    );
  }
}

class _SelectedStopHeader extends StatelessWidget {
  const _SelectedStopHeader({required this.stop});

  final StopGroup stop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _departuresContentHorizontalPadding,
        _departuresHeaderTopPadding,
        _departuresContentHorizontalPadding,
        _departuresHeaderBottomPadding,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          header: true,
          child: Text(
            key: const ValueKey('departures-selected-stop-name'),
            stop.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportFilterSkeletonRow extends StatelessWidget {
  const _TransportFilterSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _departuresFilterHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _departuresContentHorizontalPadding,
        ),
        child: Row(
          key: ValueKey('departures-filter-row'),
          children: [
            _SkeletonPill(width: 48),
            SizedBox(width: 8),
            _SkeletonPill(width: 72),
            SizedBox(width: 8),
            _SkeletonPill(width: 64),
          ],
        ),
      ),
    );
  }
}

class _TransportFilterRow extends StatelessWidget {
  const _TransportFilterRow({required this.state});

  static const _allFilterValue = 'all';

  final DeparturesState state;

  @override
  Widget build(BuildContext context) {
    final selectedMode = state.selectedTransportMode;
    final modes = state.availableTransportModes;
    final filters = [
      PidFilterChipData(
        value: _allFilterValue,
        label: context.t.departures.filterAll,
      ),
      for (final mode in modes)
        PidFilterChipData(
          value: mode.name,
          label: _transportModeLabel(context, mode),
          icon: _transportModeIcon(mode),
        ),
    ];

    return SizedBox(
      height: _departuresFilterHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _departuresContentHorizontalPadding,
          ),
          child: PidFilterChips(
            key: const ValueKey('departures-filter-row'),
            filters: filters,
            selectedValue: selectedMode?.name ?? _allFilterValue,
            onSelected: (value) {
              context.read<DeparturesBloc>().add(
                DeparturesTransportFilterSelected(
                  value == _allFilterValue
                      ? null
                      : _transportModeFromValue(value, modes),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

PidTransportMode? _transportModeFromValue(
  String value,
  List<PidTransportMode> modes,
) {
  for (final mode in modes) {
    if (mode.name == value) {
      return mode;
    }
  }

  return null;
}

IconData _transportModeIcon(PidTransportMode mode) {
  return switch (mode) {
    PidTransportMode.metro => Icons.directions_subway_rounded,
    PidTransportMode.tram => Icons.tram_rounded,
    PidTransportMode.bus => Icons.directions_bus_rounded,
    PidTransportMode.trolleybus => Icons.electric_rickshaw_rounded,
    PidTransportMode.train => Icons.train_rounded,
    PidTransportMode.ferry => Icons.directions_boat_rounded,
    PidTransportMode.funicular => Icons.cable_rounded,
    PidTransportMode.unknown => Icons.more_horiz_rounded,
  };
}

class _LastUpdatedRow extends StatelessWidget {
  const _LastUpdatedRow({required this.state});

  final DeparturesState state;

  @override
  Widget build(BuildContext context) {
    final lastUpdated = state.lastUpdated;
    if (lastUpdated == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _departuresContentHorizontalPadding,
        _departuresLastUpdatedTopPadding,
        _departuresContentHorizontalPadding,
        _departuresLastUpdatedBottomPadding,
      ),
      child: Row(
        key: const ValueKey('departures-last-updated-row'),
        children: [
          SizedBox.square(
            dimension: 14,
            child: state.isRefreshing
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          LiveRelativeTimeText.departuresLastUpdated(
            timestamp: lastUpdated,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshableDeparturesContent extends StatelessWidget {
  const _RefreshableDeparturesContent({
    required this.state,
    required this.onOpenVehicleMap,
  });

  final DeparturesState state;
  final ValueChanged<VehicleMapArgs> onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    if (state.status == DeparturesStatus.error) {
      final strings = context.t;
      final details = userMessageForAppError(
        state.error,
        fallbackMessage: strings.departures.loadFailed,
        invalidDataMessage: strings.departures.invalidData,
      );

      return CenteredScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _departuresContentHorizontalPadding,
          ),
          child: ErrorStateView(
            message: strings.departures.loadFailed,
            details: details == strings.departures.loadFailed ? null : details,
            onRetry: () {
              context.read<DeparturesBloc>().add(const DeparturesRetried());
            },
          ),
        ),
      );
    }

    final visibleDepartures = state.visibleDepartures;
    if (state.status == DeparturesStatus.empty || visibleDepartures.isEmpty) {
      return CenteredScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _departuresContentHorizontalPadding,
          ),
          child: EmptyStateView(
            message: state.selectedTransportMode == null
                ? context.t.departures.empty
                : context.t.departures.emptyFilter,
            icon: Icons.departure_board_outlined,
          ),
        ),
      );
    }

    return _DeparturesList(
      state: state,
      departures: visibleDepartures,
      timeDisplayMode: state.timeDisplayMode,
      onOpenVehicleMap: onOpenVehicleMap,
      onToggleTimeDisplayMode: () {
        context.read<DeparturesBloc>().add(
          const DeparturesTimeDisplayModeToggled(),
        );
      },
    );
  }
}

class _DeparturesLoadingSkeleton extends StatelessWidget {
  const _DeparturesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('departures-loading-skeleton'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        _departuresContentHorizontalPadding,
        _departuresListTopPadding,
        _departuresContentHorizontalPadding,
        _departuresListBottomPadding,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: _departuresListGap),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _LoadingStatusCard();
        }

        return const _DepartureSkeletonCard();
      },
    );
  }
}

class _LoadingStatusCard extends StatelessWidget {
  const _LoadingStatusCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.t.departures.loading,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const _LongLoadingMessage(),
          ],
        ),
      ),
    );
  }
}

class _LongLoadingMessage extends StatefulWidget {
  const _LongLoadingMessage();

  @override
  State<_LongLoadingMessage> createState() => _LongLoadingMessageState();
}

class _LongLoadingMessageState extends State<_LongLoadingMessage> {
  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    return Flexible(
      child: Text(
        context.t.departures.loadingLong,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DepartureSkeletonCard extends StatelessWidget {
  const _DepartureSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _SkeletonBox(width: 58, height: 48, radius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(widthFactor: 0.76, height: 14),
                      SizedBox(height: 8),
                      _SkeletonBar(widthFactor: 0.48, height: 10),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SkeletonBox(width: 62, height: 14, radius: 999),
                    SizedBox(height: 8),
                    _SkeletonBox(width: 44, height: 10, radius: 999),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 70),
              child: _SkeletonBar(widthFactor: 0.58, height: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  const _SkeletonPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: width, height: 32, radius: 999);
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: _SkeletonBox(width: double.infinity, height: height, radius: 999),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}

class _DeparturesList extends StatelessWidget {
  const _DeparturesList({
    required this.state,
    required this.departures,
    required this.timeDisplayMode,
    required this.onOpenVehicleMap,
    required this.onToggleTimeDisplayMode,
  });

  final DeparturesState state;
  final List<Departure> departures;
  final DepartureTimeDisplayMode timeDisplayMode;
  final ValueChanged<VehicleMapArgs> onOpenVehicleMap;
  final VoidCallback onToggleTimeDisplayMode;

  @override
  Widget build(BuildContext context) {
    final sections = groupDeparturesByPlatform(
      departures,
      platformLabelBuilder: (platform) =>
          context.t.departures.platform(platform: platform),
      unknownPlatformLabel: context.t.departures.platformUnknown,
    );
    final showUnknownPlatformHeader =
        sections.length > 1 ||
        sections.any((section) => section.platformCode != null);

    return ListView(
      key: const ValueKey('departures-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        _departuresContentHorizontalPadding,
        _departuresListTopPadding,
        _departuresContentHorizontalPadding,
        _departuresListBottomPadding,
      ),
      children: [
        if (state.refreshError != null) ...[
          _RefreshWarning(error: state.refreshError),
          const SizedBox(height: _departuresListGap),
        ],
        for (var index = 0; index < sections.length; index++) ...[
          _DeparturePlatformSectionView(
            section: sections[index],
            showUnknownPlatformHeader: showUnknownPlatformHeader,
            timeDisplayMode: timeDisplayMode,
            referenceTime: state.lastUpdated,
            onOpenVehicleMap: onOpenVehicleMap,
            onToggleTimeDisplayMode: onToggleTimeDisplayMode,
          ),
          if (index < sections.length - 1)
            const SizedBox(height: _departuresListGap + 4),
        ],
      ],
    );
  }
}

class _DeparturePlatformSectionView extends StatelessWidget {
  const _DeparturePlatformSectionView({
    required this.section,
    required this.showUnknownPlatformHeader,
    required this.timeDisplayMode,
    required this.onOpenVehicleMap,
    required this.onToggleTimeDisplayMode,
    this.referenceTime,
  });

  final DeparturePlatformSection section;
  final bool showUnknownPlatformHeader;
  final DepartureTimeDisplayMode timeDisplayMode;
  final DateTime? referenceTime;
  final ValueChanged<VehicleMapArgs> onOpenVehicleMap;
  final VoidCallback onToggleTimeDisplayMode;

  bool get _showHeader {
    return section.platformCode != null || showUnknownPlatformHeader;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showHeader) ...[
          _DeparturePlatformHeader(section: section),
          const SizedBox(height: 6),
        ],
        for (var index = 0; index < section.departures.length; index++) ...[
          _DepartureListTile(
            departure: section.departures[index],
            timeDisplayMode: timeDisplayMode,
            referenceTime: referenceTime,
            onOpenVehicleMap: onOpenVehicleMap,
            onToggleTimeDisplayMode: onToggleTimeDisplayMode,
          ),
          if (index < section.departures.length - 1)
            const SizedBox(height: _departuresListGap),
        ],
      ],
    );
  }
}

class _DeparturePlatformHeader extends StatelessWidget {
  const _DeparturePlatformHeader({required this.section});

  final DeparturePlatformSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      header: true,
      child: DecoratedBox(
        key: ValueKey(
          'departure-platform-section-${section.platformCode ?? 'unknown'}',
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            section.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartureListTile extends StatelessWidget {
  const _DepartureListTile({
    required this.departure,
    required this.timeDisplayMode,
    required this.onOpenVehicleMap,
    required this.onToggleTimeDisplayMode,
    this.referenceTime,
  });

  final Departure departure;
  final DepartureTimeDisplayMode timeDisplayMode;
  final DateTime? referenceTime;
  final ValueChanged<VehicleMapArgs> onOpenVehicleMap;
  final VoidCallback onToggleTimeDisplayMode;

  @override
  Widget build(BuildContext context) {
    // Departure boards can omit vehicle.id. A separate lookup would be needed;
    // do not fake vehicle tracking from gtfsTripId.
    final mapArgs = VehicleMapArgs.fromDeparture(departure);

    return DepartureTile(
      departure: departure,
      timeDisplayMode: timeDisplayMode,
      referenceTime: referenceTime,
      showPlatform: false,
      onToggleTimeDisplayMode: onToggleTimeDisplayMode,
      onOpenVehicleMap: mapArgs == null
          ? null
          : () => onOpenVehicleMap(mapArgs),
    );
  }
}

String _transportModeLabel(BuildContext context, PidTransportMode mode) {
  final strings = context.t.departures;

  return switch (mode) {
    PidTransportMode.metro => strings.filterMetro,
    PidTransportMode.tram => strings.filterTram,
    PidTransportMode.bus => strings.filterBus,
    PidTransportMode.trolleybus => strings.filterTrolleybus,
    PidTransportMode.train => strings.filterTrain,
    PidTransportMode.ferry => strings.filterFerry,
    PidTransportMode.funicular => strings.filterFunicular,
    PidTransportMode.unknown => strings.filterOther,
  };
}

class _RefreshWarning extends StatelessWidget {
  const _RefreshWarning({required this.error});

  final AppFailure? error;

  @override
  Widget build(BuildContext context) {
    final message = userMessageForAppError(
      error,
      fallbackMessage: context.t.errors.refreshFailed,
    );
    final strings = context.t;

    return PidStatusBanner(
      tone: PidStatusBannerTone.error,
      icon: Icons.info_outline,
      title: strings.departures.staleWarning,
      message: message,
    );
  }
}
