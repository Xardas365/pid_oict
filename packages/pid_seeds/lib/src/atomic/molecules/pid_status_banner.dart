import 'package:flutter/material.dart';

import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';

enum PidStatusBannerTone { info, warning, error }

class PidStatusBanner extends StatelessWidget {
  const PidStatusBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = PidStatusBannerTone.info,
    this.icon,
  });

  final String? title;
  final String message;
  final PidStatusBannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(context, tone);

    return Material(
      color: colors.background,
      borderRadius: PidSeedRadius.card,
      child: Padding(
        padding: const EdgeInsets.all(PidSeedSpacing.md),
        child: Row(
          children: [
            Icon(icon ?? _iconFor(tone), color: colors.foreground, size: 20),
            const SizedBox(width: PidSeedSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: PidSeedSpacing.xxs),
                  ],
                  Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colors.foreground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PidStatusBannerColors _colorsFor(
    BuildContext context,
    PidStatusBannerTone tone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (tone) {
      PidStatusBannerTone.info => _PidStatusBannerColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
        ),
      PidStatusBannerTone.warning => _PidStatusBannerColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
        ),
      PidStatusBannerTone.error => _PidStatusBannerColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
        ),
    };
  }

  IconData _iconFor(PidStatusBannerTone tone) {
    return switch (tone) {
      PidStatusBannerTone.info => Icons.info_outline_rounded,
      PidStatusBannerTone.warning => Icons.warning_amber_rounded,
      PidStatusBannerTone.error => Icons.info_outline_rounded,
    };
  }
}

class _PidStatusBannerColors {
  const _PidStatusBannerColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
