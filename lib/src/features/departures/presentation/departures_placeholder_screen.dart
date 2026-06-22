import 'package:flutter/material.dart';

import '../../stops/domain/stop.dart';

class DeparturesPlaceholderScreen extends StatelessWidget {
  const DeparturesPlaceholderScreen({required this.stop, super.key});

  final Stop stop;

  @override
  Widget build(BuildContext context) {
    // Temporary placeholder for seed 05, where the real departures UI is added.
    return Scaffold(
      appBar: AppBar(title: Text(stop.name)),
      body: const Center(child: Text('Odjezdy budou doplneny v dalsim kroku.')),
    );
  }
}
