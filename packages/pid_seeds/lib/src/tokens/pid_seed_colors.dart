import 'package:flutter/material.dart';

/// Color tokens used by PID Seeds.
class PidSeedColors {
  const PidSeedColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEAF2FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);

  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0F766E);
  static const Color tealSoft = Color(0xFFDDF8F3);

  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFF92400E);
  static const Color amberSoft = Color(0xFFFFF4DB);

  static const Color background = Color(0xFFF6F8FB);
  static const Color mapBackgroundTop = Color(0xFFF8FBFF);
  static const Color mapBackgroundBottom = Color(0xFFEEF6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = tealDark;
  static const Color warning = amber;
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, teal],
  );

  static const LinearGradient mapGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mapBackgroundTop, mapBackgroundBottom],
  );
}
