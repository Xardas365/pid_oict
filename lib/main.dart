import 'package:flutter/material.dart';

import 'src/features/stops/domain/stop.dart';
import 'src/features/stops/presentation/stops_screen.dart';

void main() {
  runApp(const PidOictApp());
}

class PidOictApp extends StatelessWidget {
  const PidOictApp({super.key, this.loadStops});

  final Future<List<Stop>> Function()? loadStops;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PID Odjezdy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: StopsScreen(loadStops: loadStops),
    );
  }
}
