import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
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
    this.semanticLabel,
    this.onTap,
    this.trailingAction,
  });

  final PidStopData stop;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final PidStopCardAction? trailingAction;

  @override
  Widget build(BuildContext context) {
    final accent = stop.transportType.foreground;
    final iconBackground = stop.transportType.background;
    final cardBackground =
        stop.isHighlighted ? PidSeedColors.primarySoft : PidSeedColors.surface;
    final borderColor =
        stop.isHighlighted ? PidSeedColors.primaryBorder : PidSeedColors.border;

    return Material(
      color: cardBackground,
      borderRadius: PidSeedRadius.card,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: PidSeedRadius.card,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label:
                    semanticLabel ?? t.stopCard.semanticLabel(name: stop.name),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: PidSeedRadius.card,
                  child: Padding(
                    padding: const EdgeInsets.all(PidSeedSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: accent,
                            size: 23,
                          ),
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
                              Text(
                                stop.distanceText!,
                                style: PidSeedTypography.caption.copyWith(
                                  color: PidSeedColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(width: PidSeedSpacing.md),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: PidSeedColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (trailingAction != null)
              Padding(
                padding: const EdgeInsets.only(right: PidSeedSpacing.sm),
                child: IconButton(
                  tooltip: trailingAction!.tooltip,
                  onPressed: trailingAction!.onPressed,
                  icon: Icon(trailingAction!.icon),
                  color: trailingAction!.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@immutable
class PidStopCardAction {
  const PidStopCardAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
}
