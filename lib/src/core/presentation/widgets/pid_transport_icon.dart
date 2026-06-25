import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/pid_line_type.dart';
import '../pid_transport_visuals.dart';

class PidTransportIcon extends StatelessWidget {
  const PidTransportIcon({
    required this.lineType,
    super.key,
    this.size = 24,
    this.preferAsset = true,
  });

  final PidLineType lineType;
  final double size;
  final bool preferAsset;

  @override
  Widget build(BuildContext context) {
    final visual = lineType.visual;
    final assetPath = visual.assetPath;
    final fallback = Icon(
      visual.fallbackIcon,
      size: size,
      semanticLabel: visual.semanticLabel,
    );

    if (!preferAsset || assetPath == null) {
      return fallback;
    }

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      semanticsLabel: visual.semanticLabel,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
