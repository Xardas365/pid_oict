import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_typography.dart';

class PidSectionTitle extends StatelessWidget {
  const PidSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing ??
        (actionLabel == null
            ? null
            : TextButton(
                onPressed: onActionPressed,
                child: Text(
                  actionLabel!,
                  style: PidSeedTypography.label
                      .copyWith(color: PidSeedColors.primary),
                ),
              ));

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: PidSeedTypography.sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingWidget != null) trailingWidget,
      ],
    );
  }
}
