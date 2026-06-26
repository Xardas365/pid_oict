import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/domain/pid_line_type.dart';
import '../../../../core/presentation/pid_transport_visuals.dart';
import '../../../../shared/utils/date_time_formatters.dart';
import '../../domain/departure.dart';
import '../departure_time_display_mode.dart';
import 'departure_delay_badge.dart';

const double _lineBadgeWidth = 56;
const double _lineBadgeHeight = 44;
const double _lineBadgeGap = 12;
const double _timeBlockWidth = 72;

class DepartureTile extends StatelessWidget {
  const DepartureTile({
    required this.departure,
    required this.timeDisplayMode,
    required this.onToggleTimeDisplayMode,
    required this.onOpenVehicleMap,
    super.key,
    this.referenceTime,
  });

  final Departure departure;
  final DepartureTimeDisplayMode timeDisplayMode;
  final DateTime? referenceTime;
  final VoidCallback onToggleTimeDisplayMode;
  final VoidCallback? onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    final onOpenVehicleMap = this.onOpenVehicleMap;
    final hasTracking = onOpenVehicleMap != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onOpenVehicleMap != null,
        child: InkWell(
          onTap: onOpenVehicleMap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DepartureMainRow(
                  departure: departure,
                  timeDisplayMode: timeDisplayMode,
                  referenceTime: referenceTime,
                  onToggleTimeDisplayMode: onToggleTimeDisplayMode,
                ),
                if (_hasMetadata(departure, hasTracking)) ...[
                  const SizedBox(height: 6),
                  _DepartureMetadataSection(
                    departure: departure,
                    hasTracking: hasTracking,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _hasMetadata(Departure departure, bool hasTracking) {
  return departure.platform != null ||
      departure.isWheelchairAccessible == true ||
      departure.lineType.isNight ||
      hasTracking;
}

class _DepartureMainRow extends StatelessWidget {
  const _DepartureMainRow({
    required this.departure,
    required this.timeDisplayMode,
    required this.onToggleTimeDisplayMode,
    this.referenceTime,
  });

  final Departure departure;
  final DepartureTimeDisplayMode timeDisplayMode;
  final DateTime? referenceTime;
  final VoidCallback onToggleTimeDisplayMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _DepartureLineBadge(departure: departure),
        const SizedBox(width: _lineBadgeGap),
        Expanded(
          child: Text(
            departure.headsign,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        _DepartureTimeBlock(
          departure: departure,
          mode: timeDisplayMode,
          referenceTime: referenceTime,
          onToggle: onToggleTimeDisplayMode,
        ),
      ],
    );
  }
}

class _DepartureLineBadge extends StatelessWidget {
  const _DepartureLineBadge({required this.departure});

  final Departure departure;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeColors = PidLineBadgeColorResolver.resolve(
      lineType: departure.lineType,
      routeShortName: departure.routeShortName,
    );

    return DecoratedBox(
      key: ValueKey('departure-route-label-${departure.routeShortName}'),
      decoration: BoxDecoration(
        color:
            routeColors?.backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: routeColors?.borderColor ?? colorScheme.outlineVariant,
        ),
      ),
      child: SizedBox(
        width: _lineBadgeWidth,
        height: _lineBadgeHeight,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                departure.routeShortName,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: routeColors?.foregroundColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartureTimeBlock extends StatelessWidget {
  const _DepartureTimeBlock({
    required this.departure,
    required this.mode,
    required this.onToggle,
    this.referenceTime,
  });

  final Departure departure;
  final DepartureTimeDisplayMode mode;
  final DateTime? referenceTime;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.departures;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final clockTime = formatClockTime(departure.departureTime);
    final topLabel = mode == DepartureTimeDisplayMode.relativeFirst
        ? formatRelativeDepartureCountdown(
            departure.departureTime.difference(
              referenceTime ?? DateTime.now(),
            ),
          )
        : clockTime;
    final bottomLabel = mode == DepartureTimeDisplayMode.relativeFirst
        ? clockTime
        : formatRealtimeDelayLabel(departure.delaySeconds);
    final bottomColor = mode == DepartureTimeDisplayMode.clockFirst
        ? _delayTextColor(context, departure.delaySeconds)
        : colorScheme.onSurfaceVariant;

    return Tooltip(
      message: strings.toggleTimeDisplay,
      child: Semantics(
        container: true,
        button: true,
        label: strings.toggleTimeDisplay,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: _timeBlockWidth,
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        topLabel,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: textTheme.titleSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bottomLabel,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall?.copyWith(
                          color: bottomColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _delayTextColor(BuildContext context, int? delaySeconds) {
  if (delaySeconds == null) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  final colorScheme = Theme.of(context).colorScheme;
  return switch (departureDelayLevel(delaySeconds)) {
    DepartureDelayLevel.low => const Color(0xFF1B6B35),
    DepartureDelayLevel.medium => const Color(0xFF7A5200),
    DepartureDelayLevel.high => colorScheme.error,
  };
}

class _DepartureMetadataSection extends StatelessWidget {
  const _DepartureMetadataSection({
    required this.departure,
    required this.hasTracking,
  });

  final Departure departure;
  final bool hasTracking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metadata = <Widget>[];
    final platform = departure.platform;
    if (platform != null) {
      metadata.add(Text(context.t.departures.platform(platform: platform)));
    }

    if (departure.isWheelchairAccessible == true) {
      metadata.add(
        _IconMetadataItem(
          icon: Icons.accessible_rounded,
          label: context.t.departures.wheelchairAccessibleShort,
        ),
      );
    }

    if (departure.lineType.isNight) {
      metadata.add(
        _TextMetadataItem(
          text: context.t.departures.nightRouteShort,
          label: context.t.departures.nightRoute,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: _lineBadgeWidth + _lineBadgeGap),
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackTracking =
                hasTracking &&
                (constraints.maxWidth < 250 || (platform?.length ?? 0) > 12);
            final metadataRow = _MetadataItemsRow(items: metadata);
            final trackingLabel = _TrackingActionLabel(
              color: colorScheme.primary,
            );

            if (!hasTracking) {
              return metadataRow;
            }

            if (stackTracking) {
              return Column(
                key: const ValueKey('departure-metadata-stacked'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (metadata.isNotEmpty) metadataRow,
                  if (metadata.isNotEmpty) const SizedBox(height: 3),
                  trackingLabel,
                ],
              );
            }

            return Row(
              key: const ValueKey('departure-metadata-inline'),
              children: [
                Expanded(child: metadataRow),
                const SizedBox(width: 10),
                trackingLabel,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetadataItemsRow extends StatelessWidget {
  const _MetadataItemsRow({required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 7,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var index = 0; index < items.length; index++)
          _MetadataWrapItem(
            showLeadingSeparator: index > 0,
            child: items[index],
          ),
      ],
    );
  }
}

class _TextMetadataItem extends StatelessWidget {
  const _TextMetadataItem({
    required this.text,
    required this.label,
  });

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        container: true,
        label: label,
        child: ExcludeSemantics(
          child: Text(text),
        ),
      ),
    );
  }
}

class _IconMetadataItem extends StatelessWidget {
  const _IconMetadataItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        container: true,
        label: label,
        child: ExcludeSemantics(
          child: Icon(
            icon,
            size: 15,
            color: DefaultTextStyle.of(context).style.color,
          ),
        ),
      ),
    );
  }
}

class _TrackingActionLabel extends StatelessWidget {
  const _TrackingActionLabel({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: context.t.departures.showVehicleTooltip,
      button: true,
      child: ExcludeSemantics(
        child: Text(
          context.t.departures.trackingHint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MetadataWrapItem extends StatelessWidget {
  const _MetadataWrapItem({
    required this.child,
    required this.showLeadingSeparator,
  });

  final Widget child;
  final bool showLeadingSeparator;

  @override
  Widget build(BuildContext context) {
    if (!showLeadingSeparator) {
      return child;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              text: '· ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
