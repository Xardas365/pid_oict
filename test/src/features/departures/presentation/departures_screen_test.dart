import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/presentation/departures_screen.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  group('DeparturesScreen', () {
    const stop = Stop(id: 'U123Z1', name: 'Staromestska');

    testWidgets('shows loaded departures and vehicle map action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeparturesScreen(
            stop: stop,
            loadDepartures: (_) async => [
              Departure(
                routeShortName: '22',
                headsign: 'Nadrazi Hostivar',
                departureTime: DateTime(2026, 6, 22, 10, 15),
                delaySeconds: 120,
                platform: '3',
                vehicleId: 'vehicle-123',
              ),
              Departure(
                routeShortName: 'A',
                headsign: 'Nemocnice Motol',
                departureTime: DateTime(2026, 6, 22, 10, 18),
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Staromestska'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(find.text('Odjezd 10:15'), findsOneWidget);
      expect(find.text('Zpozdeni +2 min'), findsOneWidget);
      expect(find.text('Nastupiste 3'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.byTooltip('Zobrazit polohu vozidla'), findsOneWidget);
    });

    testWidgets('opens vehicle map screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeparturesScreen(
            stop: stop,
            loadDepartures: (_) async => [
              Departure(
                routeShortName: '22',
                headsign: 'Nadrazi Hostivar',
                departureTime: DateTime(2026, 6, 22, 10, 15),
                vehicleId: 'vehicle-123',
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zobrazit polohu vozidla'));
      await tester.pumpAndSettle();

      expect(find.text('Poloha vozidla'), findsOneWidget);
      expect(
        find.text(
          'Chybi Golemio API token. Spustte aplikaci s GOLEMIO_API_TOKEN.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows error and retries loading departures', (
      WidgetTester tester,
    ) async {
      var attempts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DeparturesScreen(
            stop: stop,
            loadDepartures: (_) async {
              attempts += 1;
              if (attempts == 1) {
                throw const AppException(
                  type: AppExceptionType.network,
                  message: 'Network error.',
                );
              }

              return [
                Departure(
                  routeShortName: '22',
                  headsign: 'Nadrazi Hostivar',
                  departureTime: DateTime(2026, 6, 22, 10, 15),
                ),
              ];
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Nepodarilo se pripojit ke Golemio API.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Zkusit znovu'));
      await tester.pumpAndSettle();

      expect(find.text('Nadrazi Hostivar'), findsOneWidget);
      expect(attempts, 2);
    });
  });
}
