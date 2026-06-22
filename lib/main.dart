import 'package:flutter/material.dart';

import 'src/features/stops/domain/stop.dart';
import 'src/features/stops/presentation/stops_screen.dart';

const _pidRed = Color(0xFFD32F2F);
const _pidBackground = Color(0xFFFFF8F6);

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _pidRed).copyWith(
          primary: _pidRed,
          surface: Colors.white,
          surfaceContainerLowest: _pidBackground,
        ),
        scaffoldBackgroundColor: _pidBackground,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: _pidBackground,
          foregroundColor: Color(0xFF241B1C),
        ),
      ),
      home: StopsScreen(loadStops: loadStops),
    );
  }
}
