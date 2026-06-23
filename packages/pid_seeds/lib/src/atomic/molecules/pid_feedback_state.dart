import 'package:flutter/material.dart';

import '../../tokens/pid_seed_colors.dart';
import '../../tokens/pid_seed_radius.dart';
import '../../tokens/pid_seed_spacing.dart';
import '../../tokens/pid_seed_typography.dart';

class PidFeedbackState extends StatelessWidget {
  const PidFeedbackState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PidSeedSpacing.xl),
      decoration: BoxDecoration(
        color: PidSeedColors.surface,
        borderRadius: PidSeedRadius.card,
        border: Border.all(color: PidSeedColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: PidSeedColors.textMuted),
          const SizedBox(height: PidSeedSpacing.md),
          Text(title,
              textAlign: TextAlign.center, style: PidSeedTypography.cardTitle),
          const SizedBox(height: PidSeedSpacing.sm),
          Text(message,
              textAlign: TextAlign.center, style: PidSeedTypography.body),
          if (actionLabel != null) ...[
            const SizedBox(height: PidSeedSpacing.lg),
            FilledButton(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class PidLoadingState extends StatelessWidget {
  const PidLoadingState({super.key, this.label = 'Načítání...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PidSeedSpacing.xxl),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: PidSeedSpacing.lg),
          Text(label, style: PidSeedTypography.body),
        ],
      ),
    );
  }
}
