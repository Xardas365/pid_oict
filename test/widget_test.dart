import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/main.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  testWidgets('app opens the stops screen and filters loaded stops', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PidOictApp(
        loadStops: () async => const [
          Stop(id: '1', name: 'Staromestska'),
          Stop(id: '2', name: 'Andel'),
          Stop(id: '3', name: 'hr.VUSC Praha'),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Zastavky'), findsOneWidget);
    expect(find.text('Odjezdy'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('PID zastavky'), findsOneWidget);
    expect(find.text('Staromestska'), findsOneWidget);
    expect(find.text('Andel'), findsOneWidget);
    expect(find.text('hr.VUSC Praha'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'and');
    await tester.pump();

    expect(find.text('Staromestska'), findsNothing);
    expect(find.text('Andel'), findsOneWidget);
  });

  testWidgets('departures tab asks for a selected stop first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(PidOictApp(loadStops: () async => const <Stop>[]));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Odjezdy'));
    await tester.pumpAndSettle();

    expect(find.text('Nejdrive vyberte zastavku ze seznamu.'), findsOneWidget);
  });

  testWidgets('map tab asks for a selected vehicle first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(PidOictApp(loadStops: () async => const <Stop>[]));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();

    expect(
      find.text('Vyberte odjezd s dostupnou polohou vozidla.'),
      findsOneWidget,
    );
  });

  testWidgets('selecting a stop switches to departures tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PidOictApp(
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
    expect(find.text('Odjezd 10:15'), findsOneWidget);
  });

  testWidgets('selecting a vehicle switches to map tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PidOictApp(
        showMapTiles: false,
        vehicleMapRefreshInterval: Duration.zero,
        loadStops: () async => const [Stop(id: '1', name: 'Andel')],
        loadDepartures: (_) async => [
          Departure(
            routeShortName: '22',
            headsign: 'Nadrazi Hostivar',
            departureTime: DateTime(2026, 6, 22, 10, 15),
            vehicleId: 'vehicle-123',
          ),
        ],
        loadVehiclePosition: (_) async => const VehiclePosition(
          vehicleId: 'vehicle-123',
          latitude: 50.0755,
          longitude: 14.4378,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Andel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zobrazit polohu vozidla'));
    await tester.pumpAndSettle();

    expect(find.text('Poloha vozidla'), findsOneWidget);
    expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
  });
}
