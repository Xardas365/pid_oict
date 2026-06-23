import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidBadge extends StatelessWidget {
  const PidBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = PidSeedColors.primarySoft,
    this.foregroundColor = PidSeedColors.primary,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PidSeedSpacing.md,
      vertical: PidSeedSpacing.sm,
    ),
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: PidSeedSpacing.xs),
        ],
        Text(
          label,
          style: PidSeedTypography.label.copyWith(color: foregroundColor),
        ),
      ],
    );

    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: PidSeedRadius.chip,
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
