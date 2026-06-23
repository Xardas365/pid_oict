import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_typography.dart';
import '../../utils/pid_transport_type.dart';

class PidLineBadge extends StatelessWidget {
  const PidLineBadge({
    super.key,
    required this.label,
    this.transportType = PidTransportType.unknown,
    this.isWarning = false,
    this.width = 50,
    this.height = 36,
  });

  final String label;
  final PidTransportType transportType;
  final bool isWarning;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final background =
        isWarning ? PidSeedColors.amberSoft : transportType.background;
    final foreground =
        isWarning ? PidSeedColors.amber : transportType.foreground;

    return Semantics(
      label: 'Linka $label',
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: PidSeedRadius.md,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PidSeedTypography.sectionTitle.copyWith(
            color: foreground,
            fontSize: label.length > 2 ? 16 : 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
