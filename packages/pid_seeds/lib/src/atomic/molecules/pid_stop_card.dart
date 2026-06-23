import 'package:flutter/material.dart';

import '../../models/pid_stop_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../../utils/pid_transport_type.dart';
import '../atoms/pid_badge.dart';

class PidStopCard extends StatelessWidget {
  const PidStopCard({
    super.key,
    required this.stop,
    this.onTap,
  });

  final PidStopData stop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = stop.transportType.foreground;
    final iconBackground = stop.transportType.background;
    final cardBackground =
        stop.isHighlighted ? PidSeedColors.primarySoft : PidSeedColors.surface;
    final borderColor =
        stop.isHighlighted ? PidSeedColors.primaryBorder : PidSeedColors.border;

    return Semantics(
      button: true,
      label: 'Zastávka ${stop.name}',
      child: Material(
        color: cardBackground,
        borderRadius: PidSeedRadius.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: PidSeedRadius.card,
          child: Container(
            padding: const EdgeInsets.all(PidSeedSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: PidSeedRadius.card,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: iconBackground, shape: BoxShape.circle),
                  child:
                      Icon(Icons.location_on_outlined, color: accent, size: 23),
                ),
                const SizedBox(width: PidSeedSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PidSeedTypography.cardTitle,
                      ),
                      if (stop.subtitle.isNotEmpty) ...[
                        const SizedBox(height: PidSeedSpacing.xs),
                        Text(
                          stop.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PidSeedTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: PidSeedSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (stop.lineCountText != null)
                      PidBadge(
                        label: stop.lineCountText!,
                        backgroundColor: iconBackground,
                        foregroundColor: accent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: PidSeedSpacing.sm,
                          vertical: PidSeedSpacing.xs,
                        ),
                      ),
                    if (stop.distanceText != null) ...[
                      const SizedBox(height: PidSeedSpacing.sm),
                      Text(stop.distanceText!,
                          style: PidSeedTypography.caption
                              .copyWith(color: PidSeedColors.textMuted)),
                    ],
                  ],
                ),
                const SizedBox(width: PidSeedSpacing.md),
                const Icon(Icons.chevron_right_rounded,
                    color: PidSeedColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
