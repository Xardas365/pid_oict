import 'package:flutter/material.dart';

import '../../domain/pid_line_type.dart';
import '../pid_transport_visuals.dart';

class PidTransportIcon extends StatelessWidget {
  const PidTransportIcon({
    required this.lineType,
    super.key,
    this.size = 24,
    this.preferAsset = false,
  });

  final PidLineType lineType;
  final double size;
  final bool preferAsset;

  @override
  Widget build(BuildContext context) {
    final visual = lineType.visual;
    final fallback = Icon(
      visual.fallbackIcon,
      size: size,
      semanticLabel: visual.semanticLabel,
    );

    if (!preferAsset) {
      return fallback;
    }

    return Image.asset(
      visual.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: visual.semanticLabel,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
