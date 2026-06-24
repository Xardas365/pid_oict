import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/presentation/widgets/pid_transport_icon.dart';
import '../../../../shared/utils/date_time_formatters.dart';
import '../../domain/departure.dart';

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
    final delayText = formatDelaySeconds(departure.delaySeconds);
    final platform = departure.platform;
    final strings = context.t;

    return Card(
      child: ListTile(
        leading: _RouteBadge(departure: departure),
        title: Text(departure.headsign),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.departures.departureTime(
                time: formatClockTime(departure.departureTime),
              ),
            ),
            if (delayText != null) Text(delayText),
            if (platform != null)
              Text(strings.departures.platform(platform: platform)),
          ],
        ),
        trailing: onOpenVehicleMap == null
            ? null
            : IconButton(
                tooltip: strings.departures.showVehicleTooltip,
                onPressed: onOpenVehicleMap,
                icon: const Icon(Icons.map_outlined),
              ),
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  const _RouteBadge({required this.departure});

  final Departure departure;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PidTransportIcon(lineType: departure.lineType, size: 18),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              departure.routeShortName,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
