import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/presentation/widgets/pid_transport_icon.dart';
import '../../../../shared/utils/date_time_formatters.dart';
import '../../domain/departure.dart';
import 'departure_delay_badge.dart';

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
        PidTransportIcon(lineType: departure.lineType),
        const SizedBox(width: 10),
        _DepartureRouteBadge(departure: departure),
        const SizedBox(width: 12),
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

class _DepartureRouteBadge extends StatelessWidget {
  const _DepartureRouteBadge({required this.departure});

  final Departure departure;

  @override
  Widget build(BuildContext context) {
    final isAccessible = departure.isWheelchairAccessible == true;

    return SizedBox(
      width: 34,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAccessible) ...[
            Icon(
              Icons.accessible_forward,
              size: 16,
              semanticLabel: context.t.departures.wheelchairAccessible,
            ),
            const SizedBox(height: 2),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              departure.routeShortName,
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(left: 34),
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
