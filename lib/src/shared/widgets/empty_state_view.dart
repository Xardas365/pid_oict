import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

import '../../../i18n/strings.g.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PidSeedSpacing.xxl),
        child: PidFeedbackState(
          title: message,
          icon: icon,
          actionLabel: onRetry == null ? null : context.t.common.retry,
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}
