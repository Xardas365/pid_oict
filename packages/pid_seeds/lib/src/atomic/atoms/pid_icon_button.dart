import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';

class PidIconButton extends StatelessWidget {
  const PidIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.backgroundColor = PidSeedColors.primarySoft,
    this.foregroundColor = PidSeedColors.primary,
    this.size = 42,
    this.iconSize = 22,
    this.borderRadius = PidSeedRadius.md,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double iconSize;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: onPressed == null ? PidSeedColors.border : backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color:
                onPressed == null ? PidSeedColors.textMuted : foregroundColor,
            size: iconSize,
          ),
        ),
      ),
    );

    child = Semantics(
      button: true,
      label: semanticLabel ?? tooltip,
      child: child,
    );

    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}
