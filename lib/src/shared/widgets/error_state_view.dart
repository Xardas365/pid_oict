import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../i18n/strings.g.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    required this.onRetry,
    super.key,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PidSeedSpacing.xxl),
        child: PidFeedbackState(
          title: message,
          icon: icon,
          actionLabel: context.t.common.retry,
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}
