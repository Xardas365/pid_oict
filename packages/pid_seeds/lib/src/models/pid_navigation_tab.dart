import 'package:flutter/material.dart';

import '../../i18n/pid_seed_strings.g.dart';

enum PidNavigationTab { stops, departures, map }

extension PidNavigationTabX on PidNavigationTab {
  String get labelCs => switch (this) {
        PidNavigationTab.stops => t.navigation.stops,
        PidNavigationTab.departures => t.navigation.departures,
        PidNavigationTab.map => t.navigation.map,
      };

  IconData get icon => switch (this) {
        PidNavigationTab.stops => Icons.location_on_outlined,
        PidNavigationTab.departures => Icons.directions_bus_rounded,
        PidNavigationTab.map => Icons.navigation_rounded,
      };
}
