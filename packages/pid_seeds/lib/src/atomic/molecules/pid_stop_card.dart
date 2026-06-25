import 'package:flutter/material.dart';

import '../../../i18n/pid_seed_strings.g.dart';
import '../../models/pid_stop_data.dart';
import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';
import '../../utils/pid_transport_type.dart';
import '../atoms/pid_badge.dart';

const _highlightedStopCardBackground = Color(0xFFF7FAFF);
const _highlightedStopCardBorder = Color(0xFFD8E7FE);
const _trailingActionWidth = 52.0;
const _trailingActionTapTarget = 48.0;

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
    final badgeBackground = stop.transportType.background;
    final cardBackground = stop.isHighlighted
        ? _highlightedStopCardBackground
        : PidSeedColors.surface;
    final borderColor =
        stop.isHighlighted ? _highlightedStopCardBorder : PidSeedColors.border;

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
                                backgroundColor: badgeBackground,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (trailingAction != null)
              SizedBox(
                width: _trailingActionWidth,
                child: Center(
                  child: IconButton(
                    tooltip: trailingAction!.tooltip,
                    onPressed: trailingAction!.onPressed,
                    icon: Icon(trailingAction!.icon),
                    color: trailingAction!.color,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: _trailingActionTapTarget,
                      height: _trailingActionTapTarget,
                    ),
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: stop.isHighlighted
                          ? PidSeedColors.surface.withValues(alpha: 0.72)
                          : Colors.transparent,
                      hoverColor: PidSeedColors.primarySoft.withValues(
                        alpha: 0.7,
                      ),
                      highlightColor: PidSeedColors.primarySoft,
                      minimumSize: const Size.square(_trailingActionTapTarget),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
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
