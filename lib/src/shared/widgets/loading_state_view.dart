import 'package:flutter/material.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
