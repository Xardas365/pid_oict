import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidRefreshStatusCard extends StatelessWidget {
  const PidRefreshStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PidSeedColors.primarySoft,
      borderRadius: PidSeedRadius.card,
      child: InkWell(
        onTap: onRefresh,
        borderRadius: PidSeedRadius.card,
        child: Container(
          padding: const EdgeInsets.all(PidSeedSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: PidSeedRadius.card,
            border: Border.all(color: PidSeedColors.primaryBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: PidSeedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sync_rounded,
                    color: PidSeedColors.primary, size: 20),
              ),
              const SizedBox(width: PidSeedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: PidSeedTypography.bodyStrong
                            .copyWith(color: PidSeedColors.primaryDark)),
                    const SizedBox(height: PidSeedSpacing.xs),
                    Text(
                      subtitle,
                      style: PidSeedTypography.caption.copyWith(
                        color: PidSeedColors.primaryDark.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
