import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';

const int mediumDepartureDelayThresholdSeconds = 3 * 60;
const int highDepartureDelayThresholdSeconds = 10 * 60;

enum DepartureDelayLevel { low, medium, high }

DepartureDelayLevel departureDelayLevel(int delaySeconds) {
  if (delaySeconds >= highDepartureDelayThresholdSeconds) {
    return DepartureDelayLevel.high;
  }

  if (delaySeconds >= mediumDepartureDelayThresholdSeconds) {
    return DepartureDelayLevel.medium;
  }

  return DepartureDelayLevel.low;
}

String formatDepartureDelayShort(int delaySeconds) {
  if (delaySeconds <= 0) {
    return t.format.delayOnTimeShort;
  }

  final minutes = (delaySeconds + 59) ~/ 60;

  return t.format.delayMinutesShort(minutes: minutes);
}

class DepartureDelayBadge extends StatelessWidget {
  const DepartureDelayBadge({required this.delaySeconds, super.key});

  final int delaySeconds;

  @override
  Widget build(BuildContext context) {
    final level = departureDelayLevel(delaySeconds);
    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor) = switch (level) {
      DepartureDelayLevel.low => (
        const Color(0xFFE2F4E8),
        const Color(0xFF1B6B35),
      ),
      DepartureDelayLevel.medium => (
        const Color(0xFFFFF2CC),
        const Color(0xFF7A5200),
      ),
      DepartureDelayLevel.high => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          formatDepartureDelayShort(delaySeconds),
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
