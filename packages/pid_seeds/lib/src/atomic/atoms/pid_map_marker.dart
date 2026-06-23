import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_shadows.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidVehicleMapMarker extends StatelessWidget {
  const PidVehicleMapMarker({
    super.key,
    required this.lineLabel,
    this.backgroundColor = PidSeedColors.primary,
    this.foregroundColor = Colors.white,
    this.semanticLabel,
  });

  final String lineLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Aktuální poloha vozidla linky $lineLabel',
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: -7,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: PidSeedRadius.xs,
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: PidSeedShadows.card,
            ),
            alignment: Alignment.center,
            child: Text(
              lineLabel,
              style: PidSeedTypography.bodyStrong.copyWith(
                color: foregroundColor,
                fontSize: lineLabel.length > 2 ? 13 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            top: -34,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PidSeedSpacing.md,
                vertical: PidSeedSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: PidSeedColors.surface,
                borderRadius: PidSeedRadius.chip,
                boxShadow: PidSeedShadows.soft,
              ),
              child: Text(
                'živě',
                style: PidSeedTypography.label
                    .copyWith(color: PidSeedColors.tealDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
