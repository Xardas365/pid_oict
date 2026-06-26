import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/app/app_dependencies.dart';
import 'package:pid_oict/src/app/pid_oict_shell.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/presentation/bloc/departures_bloc.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_seeds/i18n/pid_seed_strings.g.dart' as pid_seed_strings;
import 'package:pid_seeds/pid_seeds.dart';

import 'in_memory_saved_stops_data_source.dart';
import 'in_memory_stops_cache_data_source.dart';

class PidOictTestApp extends StatefulWidget {
  const PidOictTestApp({
    super.key,
    this.locale = AppLocale.cs,
    this.loadStops,
    this.loadDepartures,
    this.loadVehiclePosition,
    this.departureRefreshInterval = departureBoardRefreshInterval,
    this.vehicleMapRefreshInterval = const Duration(seconds: 15),
    this.showMapTiles = true,
  });

  final AppLocale locale;
  final Future<List<Stop>> Function()? loadStops;
  final Future<List<Departure>> Function(StopGroup stop)? loadDepartures;
  final Future<VehiclePosition> Function(String vehicleId)? loadVehiclePosition;
  final Duration departureRefreshInterval;
  final Duration vehicleMapRefreshInterval;
  final bool showMapTiles;

  @override
  State<PidOictTestApp> createState() => _PidOictTestAppState();
}

class _PidOictTestAppState extends State<PidOictTestApp> {
  @override
  void initState() {
    super.initState();
    _setLocale(widget.locale);
  }

  @override
  void didUpdateWidget(PidOictTestApp oldWidget) {
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
              stopsRepository: _CallbackStopsRepository(
                widget.loadStops ?? () async => const <Stop>[],
              ),
              departuresRepository: _CallbackDeparturesRepository(
                widget.loadDepartures ?? (_) async => const <Departure>[],
              ),
              vehiclePositionRepository: _CallbackVehiclePositionRepository(
                widget.loadVehiclePosition ??
                    (_) async => const VehiclePosition(
                      vehicleId: 'test-vehicle',
                      latitude: 50.0755,
                      longitude: 14.4378,
                    ),
              ),
              stopsCacheDataSource: InMemoryStopsCacheDataSource(),
              savedStopsDataSource: InMemorySavedStopsDataSource(),
              child: PidOictShell(
                departureRefreshInterval: widget.departureRefreshInterval,
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

class _CallbackStopsRepository implements StopsRepository {
  const _CallbackStopsRepository(this._loadStops);

  final Future<List<Stop>> Function() _loadStops;

  @override
  Future<List<Stop>> fetchStops() {
    return _loadStops();
  }
}

class _CallbackDeparturesRepository implements DeparturesRepository {
  const _CallbackDeparturesRepository(this._loadDepartures);

  final Future<List<Departure>> Function(StopGroup stop) _loadDepartures;

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) {
    return _loadDepartures(stop);
  }
}

class _CallbackVehiclePositionRepository implements VehiclePositionRepository {
  const _CallbackVehiclePositionRepository(this._loadVehiclePosition);

  final Future<VehiclePosition> Function(String vehicleId) _loadVehiclePosition;

  @override
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId) {
    return _loadVehiclePosition(vehicleId.value);
  }
}
