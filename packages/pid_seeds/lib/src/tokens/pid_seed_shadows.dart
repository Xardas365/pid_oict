import 'package:flutter/material.dart';

import 'pid_seed_colors.dart';

/// Shadow tokens intentionally kept soft for public transport UI.
class PidSeedShadows {
  const PidSeedShadows._();

  static final List<BoxShadow> soft = [
    BoxShadow(
      color: PidSeedColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: PidSeedColors.textPrimary.withValues(alpha: 0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
