import 'package:flutter/material.dart';

import '../tokens/pid_seed_colors.dart';
import '../tokens/pid_seed_radius.dart';
import '../tokens/pid_seed_spacing.dart';
import '../tokens/pid_seed_typography.dart';

/// App-wide Material theme configured from PID Seeds tokens.
class PidSeedsTheme {
  const PidSeedsTheme._();

  static ThemeData light({String? fontFamily}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PidSeedColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: PidSeedColors.primary,
      secondary: PidSeedColors.teal,
      tertiary: PidSeedColors.amber,
      surface: PidSeedColors.surface,
      error: PidSeedColors.error,
    );

    TextStyle withFont(TextStyle style) =>
        fontFamily == null ? style : style.copyWith(fontFamily: fontFamily);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PidSeedColors.background,
      fontFamily: fontFamily,
      textTheme: TextTheme(
        displaySmall: withFont(PidSeedTypography.screenTitle),
        titleLarge: withFont(PidSeedTypography.sectionTitle),
        titleMedium: withFont(PidSeedTypography.cardTitle),
        bodyLarge: withFont(PidSeedTypography.bodyStrong),
        bodyMedium: withFont(PidSeedTypography.body),
        bodySmall: withFont(PidSeedTypography.caption),
        labelMedium: withFont(PidSeedTypography.label),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PidSeedColors.background,
        foregroundColor: PidSeedColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: PidSeedColors.surface,
        border: OutlineInputBorder(
          borderRadius: PidSeedRadius.search,
          borderSide: BorderSide(color: PidSeedColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PidSeedRadius.search,
          borderSide: BorderSide(color: PidSeedColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PidSeedRadius.search,
          borderSide: BorderSide(color: PidSeedColors.primary, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: PidSeedSpacing.lg,
          vertical: PidSeedSpacing.lg,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PidSeedColors.surface,
        selectedColor: PidSeedColors.primary,
        disabledColor: PidSeedColors.border,
        labelStyle: withFont(PidSeedTypography.label),
        secondaryLabelStyle: withFont(
          PidSeedTypography.label.copyWith(color: Colors.white),
        ),
        side: const BorderSide(color: PidSeedColors.border),
        shape: const RoundedRectangleBorder(borderRadius: PidSeedRadius.chip),
        showCheckmark: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PidSeedColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: PidSeedRadius.md),
          textStyle: withFont(PidSeedTypography.label),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PidSeedColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(borderRadius: PidSeedRadius.md),
          textStyle: withFont(PidSeedTypography.label),
        ),
      ),
    );
  }
}
