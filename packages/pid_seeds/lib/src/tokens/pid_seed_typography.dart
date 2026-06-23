import 'package:flutter/material.dart';

import 'pid_seed_colors.dart';

/// Typography tokens. The package does not bundle fonts; pass a fontFamily
/// into [PidSeedsTheme.light] from the host app when needed.
class PidSeedTypography {
  const PidSeedTypography._();

  static const TextStyle heroTitle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 1.16,
    letterSpacing: -0.2,
    color: Colors.white,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.16,
    letterSpacing: -0.2,
    color: PidSeedColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: PidSeedColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: PidSeedColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: PidSeedColors.textSecondary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: PidSeedColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: PidSeedColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: PidSeedColors.textSecondary,
  );
}
