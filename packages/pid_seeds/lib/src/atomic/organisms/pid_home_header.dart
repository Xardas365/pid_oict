import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidHomeHeader extends StatelessWidget {
  const PidHomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.directions_transit_filled_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      decoration: const BoxDecoration(
        gradient: PidSeedColors.heroGradient,
        borderRadius: PidSeedRadius.hero,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -10,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -26,
            bottom: -42,
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PidSeedSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PidSeedTypography.heroTitle),
                      const SizedBox(height: PidSeedSpacing.sm),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PidSeedTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PidSeedSpacing.lg),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: PidSeedRadius.md,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
