import 'package:flutter/material.dart';

import '../../domain/stop.dart';

class StopListTile extends StatelessWidget {
  const StopListTile({required this.stop, required this.onTap, super.key});

  final Stop stop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final platformCode = stop.platformCode;

    return ListTile(
      title: Text(stop.name),
      subtitle: platformCode == null ? null : Text('Nastupiste $platformCode'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
