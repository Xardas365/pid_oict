import 'package:flutter/material.dart';

import '../domain/pid_line_type.dart';

class PidTransportVisual {
  const PidTransportVisual({
    required this.fallbackIcon,
    this.assetPath,
    this.badgeText,
    this.color,
  });

  final String? assetPath;
  final IconData fallbackIcon;
  final String? badgeText;
  final Color? color;
}

class PidLineBadgeColors {
  const PidLineBadgeColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
}

abstract final class PidLineBadgeColorResolver {
  static const metroA = PidLineBadgeColors(
    backgroundColor: Color(0xFF007A3D),
    foregroundColor: Colors.white,
    borderColor: Color(0xFF006633),
  );

  static const metroB = PidLineBadgeColors(
    backgroundColor: Color(0xFFFFD200),
    foregroundColor: Color(0xFF1F2937),
    borderColor: Color(0xFFD9A900),
  );

  static const metroC = PidLineBadgeColors(
    backgroundColor: Color(0xFFC8102E),
    foregroundColor: Colors.white,
    borderColor: Color(0xFFA30D25),
  );

  static PidLineBadgeColors? resolve({
    required PidLineType lineType,
    required String routeShortName,
  }) {
    if (lineType != PidLineType.metro) {
      return null;
    }

    return switch (routeShortName.trim().toUpperCase()) {
      'A' => metroA,
      'B' => metroB,
      'C' => metroC,
      _ => null,
    };
  }
}

extension PidLineTypeVisuals on PidLineType {
  PidTransportVisual get visual {
    if (isNight) {
      return const PidTransportVisual(
        assetPath: PidTransportAssetPaths.night,
        fallbackIcon: Icons.nightlight_round,
        badgeText: 'N',
      );
    }

    return switch (this) {
      PidLineType.metro => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.metro,
        fallbackIcon: Icons.directions_subway_outlined,
      ),
      PidLineType.tram || PidLineType.tramSpecial => PidTransportVisual(
        assetPath: PidTransportAssetPaths.tram,
        fallbackIcon: Icons.tram_outlined,
        badgeText: this == PidLineType.tramSpecial ? 'S' : null,
      ),
      PidLineType.cityBus ||
      PidLineType.regionalBus ||
      PidLineType.schoolBus => PidTransportVisual(
        assetPath: PidTransportAssetPaths.bus,
        fallbackIcon: this == PidLineType.schoolBus
            ? Icons.school_outlined
            : Icons.directions_bus_outlined,
        badgeText: this == PidLineType.schoolBus ? 'Š' : null,
      ),
      PidLineType.trolleybus => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.trolleybus,
        fallbackIcon: Icons.directions_bus_outlined,
      ),
      PidLineType.trainS ||
      PidLineType.trainR ||
      PidLineType.trainInterregional ||
      PidLineType.trainTourist => PidTransportVisual(
        assetPath: PidTransportAssetPaths.train,
        fallbackIcon: Icons.train_outlined,
        badgeText: switch (this) {
          PidLineType.trainS => 'S',
          PidLineType.trainR => 'R',
          PidLineType.trainTourist => 'T',
          _ => null,
        },
      ),
      PidLineType.ferry => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.ferry,
        fallbackIcon: Icons.directions_boat_outlined,
      ),
      PidLineType.funicular => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.funicular,
        fallbackIcon: Icons.train_outlined,
      ),
      PidLineType.specialOther ||
      PidLineType.unknown => const PidTransportVisual(
        fallbackIcon: Icons.help_outline,
      ),
      PidLineType.replacementMetro => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.metro,
        fallbackIcon: Icons.directions_subway_outlined,
        badgeText: 'X',
      ),
      PidLineType.replacementTram => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.tram,
        fallbackIcon: Icons.tram_outlined,
        badgeText: 'X',
      ),
      PidLineType.replacementBus => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.bus,
        fallbackIcon: Icons.directions_bus_outlined,
        badgeText: 'X',
      ),
      PidLineType.replacementTrain => const PidTransportVisual(
        assetPath: PidTransportAssetPaths.train,
        fallbackIcon: Icons.train_outlined,
        badgeText: 'X',
      ),
      PidLineType.replacementUnknown => const PidTransportVisual(
        fallbackIcon: Icons.swap_horiz_outlined,
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
