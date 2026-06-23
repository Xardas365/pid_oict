import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';

class PidStatusDot extends StatelessWidget {
  const PidStatusDot({
    super.key,
    this.color = PidSeedColors.teal,
    this.size = 8,
    this.semanticLabel,
  });

  final Color color;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
