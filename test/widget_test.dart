import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/i18n/strings.g.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

import 'helpers/pid_oict_test_app.dart';

void main() {
  testWidgets('app opens the stops screen and filters loaded stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      PidOictTestApp(
        loadStops: () async => const [
          Stop(id: '1', name: 'Staromestska'),
          Stop(id: '2', name: 'Andel'),
          Stop(id: '3', name: 'hr.VUSC Praha'),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Zastávky'), findsNothing);
    expect(find.text('Odjezdy'), findsNothing);
    expect(find.text('Mapa'), findsNothing);
    expect(find.text('PID zastávky'), findsOneWidget);
    expect(find.text('Staromestska'), findsOneWidget);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('hr.VUSC Praha'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Staromestska'), findsNothing);
    expect(find.text('Andel'), findsOneWidget);
  });

  testWidgets('app can render English locale', (tester) async {
    await tester.pumpWidget(
      PidOictTestApp(
        locale: AppLocale.en,
        loadStops: () async => const <Stop>[],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stops'), findsNothing);
    expect(find.text('Departures'), findsNothing);
    expect(find.text('Map'), findsNothing);
    expect(find.text('PID stops'), findsOneWidget);
  });

  testWidgets('selecting a stop opens departures', (
    tester,
  ) async {
    await tester.pumpWidget(
      PidOictTestApp(
        loadStops: () async => const [Stop(id: '1', name: 'Andel')],
        loadDepartures: (_) async => [
          Departure(
            routeShortName: 'B',
            headsign: 'Cerny Most',
            departureTime: DateTime(2026, 6, 22, 10, 15),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();

    expect(find.text('Cerny Most'), findsOneWidget);
    expect(find.text('10:15'), findsOneWidget);
  });

  testWidgets('selecting a departure vehicle opens nested map detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      PidOictTestApp(
        showMapTiles: false,
        vehicleMapRefreshInterval: Duration.zero,
        loadStops: () async => const [Stop(id: '1', name: 'Andel')],
        loadDepartures: (_) async => [
          Departure(
            routeShortName: '22',
            headsign: 'Nadrazi Hostivar',
            departureTime: DateTime(2026, 6, 22, 10, 15),
            gtfsTripId: 'trip-22-123',
            vehicleId: 'service-3-1001',
          ),
        ],
        loadVehiclePosition: (vehicleId) async {
          expect(vehicleId, 'service-3-1001');

          return const VehiclePosition(
            vehicleId: 'vehicle-123',
            latitude: 50.0755,
            longitude: 14.4378,
          );
        },
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nadrazi Hostivar'));
    await tester.pumpAndSettle();

    expect(find.text('22 – Nadrazi Hostivar'), findsWidgets);
    expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);

    await tester.tap(find.byTooltip('Zpět na odjezdy'));
    await tester.pumpAndSettle();

    expect(find.text('Nadrazi Hostivar'), findsOneWidget);
  });
}
