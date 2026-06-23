import 'package:flutter/material.dart';
import 'package:pid_seeds/pid_seeds.dart';

void main() {
  runApp(const PidSeedsExampleApp());
}

class PidSeedsExampleApp extends StatelessWidget {
  const PidSeedsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PID Seeds Example',
      debugShowCheckedModeBanner: false,
      theme: PidSeedsTheme.light(),
      home: const _DemoShell(),
    );
  }
}

class _DemoShell extends StatefulWidget {
  const _DemoShell();

  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  PidNavigationTab _tab = PidNavigationTab.stops;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return switch (_tab) {
      PidNavigationTab.stops => PidStopsTemplate(
          stops: _stops,
          selectedFilter: 'all',
          filters: PidFilterChipData.pidTransportDefaults,
          onRefresh: _refresh,
          onStopSelected: (_) =>
              setState(() => _tab = PidNavigationTab.departures),
          selectedTab: _tab,
          onTabSelected: (tab) => setState(() => _tab = tab),
        ),
      PidNavigationTab.departures => PidDeparturesTemplate(
          stopName: 'Hradčanská',
          stopSubtitle: 'tram, metro A, bus',
          departures: _departures,
          updatedText: 'Aktualizováno před 12 s',
          selectedFilter: 'all',
          filters: const [
            PidFilterChipData(value: 'all', label: 'Vše'),
            PidFilterChipData(value: 'center', label: 'Centrum'),
            PidFilterChipData(value: 'dejvicka', label: 'Dejvická'),
            PidFilterChipData(value: 'letna', label: 'Letná'),
          ],
          onBack: () => setState(() => _tab = PidNavigationTab.stops),
          onRefresh: _refresh,
          onShowVehicle: (_) => setState(() => _tab = PidNavigationTab.map),
          selectedTab: _tab,
          onTabSelected: (tab) => setState(() => _tab = tab),
        ),
      PidNavigationTab.map => PidVehicleMapTemplate(
          vehicle: _vehicle,
          onBack: () => setState(() => _tab = PidNavigationTab.departures),
          onRefresh: () {
            _refresh();
          },
          onLocatePressed: () {},
          selectedTab: _tab,
          onTabSelected: (tab) => setState(() => _tab = tab),
        ),
    };
  }
}

const _stops = [
  PidStopData(
    id: 'U699Z301P',
    name: 'Hradčanská',
    subtitle: 'tram, metro A, bus',
    distanceText: '320 m',
    lineCountText: '3 linky',
    transportType: PidTransportType.tram,
    isHighlighted: true,
  ),
  PidStopData(
    id: 'U460Z101P',
    name: 'Staroměstská',
    subtitle: 'metro A, tram',
    distanceText: '610 m',
    lineCountText: '2 linky',
    transportType: PidTransportType.metro,
  ),
  PidStopData(
    id: 'U1062Z301P',
    name: 'Nádraží Holešovice',
    subtitle: 'metro C, tram, bus',
    distanceText: '1,1 km',
    lineCountText: '3 linky',
    transportType: PidTransportType.bus,
  ),
];

const _departures = [
  PidDepartureData(
    id: '26-1',
    lineLabel: '26',
    destination: 'Nádraží Hostivař',
    remainingTimeText: '3',
    platformText: 'st. A',
    vehicleId: 'vehicle-26-1',
    transportType: PidTransportType.tram,
  ),
  PidDepartureData(
    id: '8-1',
    lineLabel: '8',
    destination: 'Starý Hloubětín',
    remainingTimeText: '5',
    platformText: 'st. B',
    vehicleId: 'vehicle-8-1',
    delayText: '+2',
    transportType: PidTransportType.tram,
  ),
  PidDepartureData(
    id: '131-1',
    lineLabel: '131',
    destination: 'Bořislavka',
    remainingTimeText: '9',
    platformText: 'st. D',
    vehicleId: 'vehicle-131-1',
    transportType: PidTransportType.bus,
  ),
];

const _vehicle = PidVehiclePositionData(
  vehicleId: 'vehicle-26-1',
  lineLabel: '26',
  destination: 'Nádraží Hostivař',
  lastUpdatedText: 'Aktualizováno před 8 s',
  latitude: 50.097,
  longitude: 14.403,
  speedText: '32 km/h',
  coordinatesText: '50.097, 14.403',
  transportType: PidTransportType.tram,
);
