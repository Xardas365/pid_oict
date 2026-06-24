import 'package:flutter/material.dart';

import '../domain/pid_line_type.dart';

class PidTransportVisual {
  const PidTransportVisual({
    required this.fallbackIcon,
    required this.semanticLabel,
    this.assetPath,
    this.badgeText,
    this.color,
  });

  final String? assetPath;
  final IconData fallbackIcon;
  final String semanticLabel;
  final String? badgeText;
  final Color? color;
}

extension PidLineTypeVisuals on PidLineType {
  PidTransportVisual get visual {
    final semanticLabel = label;

    if (isNight) {
      return PidTransportVisual(
        assetPath: PidTransportAssetPaths.night,
        fallbackIcon: Icons.nightlight_round,
        semanticLabel: semanticLabel,
        badgeText: 'N',
      );
    }

    return switch (this) {
      PidLineType.metro => PidTransportVisual(
        assetPath: PidTransportAssetPaths.metro,
        fallbackIcon: Icons.directions_subway_outlined,
        semanticLabel: semanticLabel,
      ),
      PidLineType.tram || PidLineType.tramSpecial => PidTransportVisual(
        assetPath: PidTransportAssetPaths.tram,
        fallbackIcon: Icons.tram_outlined,
        semanticLabel: semanticLabel,
        badgeText: this == PidLineType.tramSpecial ? 'S' : null,
      ),
      PidLineType.cityBus ||
      PidLineType.regionalBus ||
      PidLineType.schoolBus => PidTransportVisual(
        assetPath: PidTransportAssetPaths.bus,
        fallbackIcon: this == PidLineType.schoolBus
            ? Icons.school_outlined
            : Icons.directions_bus_outlined,
        semanticLabel: semanticLabel,
        badgeText: this == PidLineType.schoolBus ? 'Š' : null,
      ),
      PidLineType.trolleybus => PidTransportVisual(
        assetPath: PidTransportAssetPaths.trolleybus,
        fallbackIcon: Icons.directions_bus_outlined,
        semanticLabel: semanticLabel,
      ),
      PidLineType.trainS ||
      PidLineType.trainR ||
      PidLineType.trainInterregional ||
      PidLineType.trainTourist => PidTransportVisual(
        assetPath: PidTransportAssetPaths.train,
        fallbackIcon: Icons.train_outlined,
        semanticLabel: semanticLabel,
        badgeText: switch (this) {
          PidLineType.trainS => 'S',
          PidLineType.trainR => 'R',
          PidLineType.trainTourist => 'T',
          _ => null,
        },
      ),
      PidLineType.ferry => PidTransportVisual(
        assetPath: PidTransportAssetPaths.ferry,
        fallbackIcon: Icons.directions_boat_outlined,
        semanticLabel: semanticLabel,
      ),
      PidLineType.funicular => PidTransportVisual(
        assetPath: PidTransportAssetPaths.funicular,
        fallbackIcon: Icons.train_outlined,
        semanticLabel: semanticLabel,
      ),
      PidLineType.specialOther || PidLineType.unknown => PidTransportVisual(
        fallbackIcon: Icons.help_outline,
        semanticLabel: semanticLabel,
      ),
      PidLineType.replacementMetro => PidTransportVisual(
        assetPath: PidTransportAssetPaths.metro,
        fallbackIcon: Icons.directions_subway_outlined,
        semanticLabel: semanticLabel,
        badgeText: 'X',
      ),
      PidLineType.replacementTram => PidTransportVisual(
        assetPath: PidTransportAssetPaths.tram,
        fallbackIcon: Icons.tram_outlined,
        semanticLabel: semanticLabel,
        badgeText: 'X',
      ),
      PidLineType.replacementBus => PidTransportVisual(
        assetPath: PidTransportAssetPaths.bus,
        fallbackIcon: Icons.directions_bus_outlined,
        semanticLabel: semanticLabel,
        badgeText: 'X',
      ),
      PidLineType.replacementTrain => PidTransportVisual(
        assetPath: PidTransportAssetPaths.train,
        fallbackIcon: Icons.train_outlined,
        semanticLabel: semanticLabel,
        badgeText: 'X',
      ),
      PidLineType.replacementUnknown => PidTransportVisual(
        fallbackIcon: Icons.swap_horiz_outlined,
        semanticLabel: semanticLabel,
        badgeText: 'X',
      ),
      PidLineType.tramNight ||
      PidLineType.cityBusNight ||
      PidLineType.regionalBusNight => throw StateError(
        'Handled before switch.',
      ),
    };
  }
}

abstract final class PidTransportAssetPaths {
  static const metro = 'assets/images/transport/travel-metro.svg';
  static const tram = 'assets/images/transport/travel-tram.svg';
  static const bus = 'assets/images/transport/travel-bus.svg';
  static const trolleybus = 'assets/images/transport/travel-trolley.svg';
  static const train = 'assets/images/transport/travel-train.svg';
  static const ferry = 'assets/images/transport/travel-ferry.svg';
  static const funicular = 'assets/images/transport/travel-cableway.svg';
  static const night = 'assets/images/transport/travel-night.svg';
}
