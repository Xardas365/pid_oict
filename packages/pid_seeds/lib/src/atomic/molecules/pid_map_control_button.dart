import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../atoms/pid_icon_button.dart';

class PidMapControlButton extends StatelessWidget {
  const PidMapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PidIconButton(
      icon: icon,
      tooltip: tooltip,
      semanticLabel: tooltip,
      onPressed: onPressed,
      backgroundColor: PidSeedColors.surface,
      foregroundColor: PidSeedColors.primary,
      borderRadius: PidSeedRadius.md,
    );
  }
}
