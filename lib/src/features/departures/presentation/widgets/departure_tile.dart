import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
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
        leading: CircleAvatar(child: Text(departure.routeShortName)),
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
