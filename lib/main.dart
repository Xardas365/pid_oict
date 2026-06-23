import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart' as pid_seed_strings;
import 'package:pid_seeds/pid_seeds.dart';

import 'i18n/strings.g.dart';
import 'src/app/app_dependencies.dart';
import 'src/app/pid_oict_shell.dart';
import 'src/features/departures/domain/departure.dart';
import 'src/features/stops/domain/stop.dart';
import 'src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  runApp(const PidOictApp());
}

class PidOictApp extends StatefulWidget {
  const PidOictApp({
    super.key,
    this.locale = AppLocale.cs,
    this.loadStops,
    this.loadDepartures,
    this.loadVehiclePosition,
    this.vehicleMapRefreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final AppLocale locale;
  final Future<List<Stop>> Function()? loadStops;
  final Future<List<Departure>> Function(Stop stop)? loadDepartures;
  final Future<VehiclePosition> Function(String gtfsTripId)?
  loadVehiclePosition;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  State<PidOictApp> createState() => _PidOictAppState();
}

class _PidOictAppState extends State<PidOictApp> {
  @override
  void initState() {
    super.initState();
    _setLocale(widget.locale);
  }

  @override
  void didUpdateWidget(PidOictApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _setLocale(widget.locale);
    }
  }

  void _setLocale(AppLocale locale) {
    LocaleSettings.setLocaleSync(locale);
    pid_seed_strings.LocaleSettings.setLocaleRawSync(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: Builder(
        builder: (context) {
          final strings = context.t;

          return MaterialApp(
            title: strings.app.title,
            theme: PidSeedsTheme.light(),
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: AppDependencies(
              child: PidOictShell(
                loadStops: widget.loadStops,
                loadDepartures: widget.loadDepartures,
                loadVehiclePosition: widget.loadVehiclePosition,
                vehicleMapRefreshInterval: widget.vehicleMapRefreshInterval,
                showMapTiles: widget.showMapTiles,
              ),
            ),
          );
        },
      ),
    );
  }
}
