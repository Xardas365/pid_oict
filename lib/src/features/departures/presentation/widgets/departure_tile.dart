import 'package:flutter/material.dart';

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
    final delayText = _formatDelay(departure.delaySeconds);
    final platform = departure.platform;

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(departure.routeShortName)),
        title: Text(departure.headsign),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odjezd ${_formatDepartureTime(departure.departureTime)}'),
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

  String _formatDepartureTime(DateTime departureTime) {
    final localTime = departureTime.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String? _formatDelay(int? delaySeconds) {
    if (delaySeconds == null) {
      return null;
    }

    if (delaySeconds <= 0) {
      return 'Zpozdeni 0 min';
    }

    final minutes = (delaySeconds / 60).round();
    return 'Zpozdeni +$minutes min';
  }
}
