import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/presentation/pid_transport_visuals.dart';
import '../../../../core/presentation/widgets/pid_transport_icon.dart';
import '../../../../shared/utils/date_time_formatters.dart';
import '../../domain/departure.dart';
import 'departure_delay_badge.dart';

const double _lineBadgeWidth = 56;
const double _lineBadgeGap = 12;

class DepartureTile extends StatelessWidget {
  const DepartureTile({
    required this.departure,
    required this.onOpenVehicleMap,
    super.key,
  });

  final Departure departure;
  final VoidCallback? onOpenVehicleMap;

  @override
  Widget build(BuildContext context) {
    final platform = departure.platform;
    final onOpenVehicleMap = this.onOpenVehicleMap;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onOpenVehicleMap != null,
        child: InkWell(
          onTap: onOpenVehicleMap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DepartureMainRow(departure: departure),
                if (platform != null) ...[
                  const SizedBox(height: 8),
                  _DeparturePlatformLabel(platform: platform),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartureMainRow extends StatelessWidget {
  const _DepartureMainRow({required this.departure});

  final Departure departure;

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        if (departure.delaySeconds != null) ...[
          DepartureDelayBadge(delaySeconds: departure.delaySeconds!),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 48,
          child: Text(
            formatClockTime(departure.departureTime),
            maxLines: 1,
            textAlign: TextAlign.right,
            style: textTheme.titleSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w800,
            ),
          ),
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
    final isAccessible = departure.isWheelchairAccessible == true;
    final colorScheme = Theme.of(context).colorScheme;
    final routeColors = PidLineBadgeColorResolver.resolve(
      lineType: departure.lineType,
      routeShortName: departure.routeShortName,
    );

    return SizedBox(
      width: _lineBadgeWidth,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PidTransportIcon(lineType: departure.lineType, size: 22),
                const SizedBox(height: 4),
                _DepartureRouteLabel(
                  routeShortName: departure.routeShortName,
                  backgroundColor:
                      routeColors?.backgroundColor ??
                      colorScheme.surfaceContainerHighest,
                  foregroundColor:
                      routeColors?.foregroundColor ?? colorScheme.onSurface,
                  borderColor:
                      routeColors?.borderColor ?? colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
          if (isAccessible)
            Positioned(
              top: -2,
              right: 0,
              child: _WheelchairIndicator(
                semanticLabel: context.t.departures.wheelchairAccessible,
              ),
            ),
        ],
      ),
    );
  }
}

class _DepartureRouteLabel extends StatelessWidget {
  const _DepartureRouteLabel({
    required this.routeShortName,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String routeShortName;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: ValueKey('departure-route-label-$routeShortName'),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: borderColor),
      ),
      child: SizedBox(
        width: 46,
        height: 24,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                routeShortName,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
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

class _WheelchairIndicator extends StatelessWidget {
  const _WheelchairIndicator({required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          Icons.accessible_forward,
          size: 14,
          color: colorScheme.primary,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}

class _DeparturePlatformLabel extends StatelessWidget {
  const _DeparturePlatformLabel({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _lineBadgeWidth + _lineBadgeGap),
      child: Text(
        context.t.departures.platform(platform: platform),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
