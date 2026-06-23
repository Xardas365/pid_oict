import 'package:flutter/material.dart';

enum PidNavigationTab { stops, departures, map }

extension PidNavigationTabX on PidNavigationTab {
  String get labelCs => switch (this) {
        PidNavigationTab.stops => 'Zastávky',
        PidNavigationTab.departures => 'Odjezdy',
        PidNavigationTab.map => 'Mapa',
      };

  IconData get icon => switch (this) {
        PidNavigationTab.stops => Icons.location_on_outlined,
        PidNavigationTab.departures => Icons.directions_bus_rounded,
        PidNavigationTab.map => Icons.navigation_rounded,
      };
}
