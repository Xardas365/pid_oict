import 'package:flutter/material.dart';

import '../../i18n/pid_seed_strings.g.dart';
import '../tokens/pid_seed_colors.dart';

/// Supported PID transport categories used for color and icon mapping.
enum PidTransportType { tram, bus, metro, train, ferry, unknown }

extension PidTransportTypeX on PidTransportType {
  String get labelCs => switch (this) {
        PidTransportType.tram => t.transport.tram,
        PidTransportType.bus => t.transport.bus,
        PidTransportType.metro => t.transport.metro,
        PidTransportType.train => t.transport.train,
        PidTransportType.ferry => t.transport.ferry,
        PidTransportType.unknown => t.transport.unknown,
      };

  IconData get icon => switch (this) {
        PidTransportType.tram => Icons.tram_rounded,
        PidTransportType.bus => Icons.directions_bus_rounded,
        PidTransportType.metro => Icons.subway_rounded,
        PidTransportType.train => Icons.train_rounded,
        PidTransportType.ferry => Icons.directions_boat_rounded,
        PidTransportType.unknown => Icons.directions_transit_rounded,
      };

  Color get foreground => switch (this) {
        PidTransportType.tram => PidSeedColors.primary,
        PidTransportType.bus => PidSeedColors.tealDark,
        PidTransportType.metro => PidSeedColors.primary,
        PidTransportType.train => PidSeedColors.tealDark,
        PidTransportType.ferry => PidSeedColors.tealDark,
        PidTransportType.unknown => PidSeedColors.textSecondary,
      };

  Color get background => switch (this) {
        PidTransportType.tram => PidSeedColors.primarySoft,
        PidTransportType.bus => PidSeedColors.tealSoft,
        PidTransportType.metro => PidSeedColors.primarySoft,
        PidTransportType.train => PidSeedColors.tealSoft,
        PidTransportType.ferry => PidSeedColors.tealSoft,
        PidTransportType.unknown => PidSeedColors.background,
      };
}
