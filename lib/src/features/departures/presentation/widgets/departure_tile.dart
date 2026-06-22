import 'package:flutter/material.dart';

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

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(departure.routeShortName)),
        title: Text(departure.headsign),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odjezd ${formatClockTime(departure.departureTime)}'),
            if (delayText != null) Text(delayText),
            if (platform != null) Text('Nastupiste $platform'),
          ],
        ),
        trailing: onOpenVehicleMap == null
            ? null
            : IconButton(
                tooltip: 'Zobrazit polohu vozidla',
                onPressed: onOpenVehicleMap,
                icon: const Icon(Icons.map_outlined),
              ),
      ),
    );
  }
}
