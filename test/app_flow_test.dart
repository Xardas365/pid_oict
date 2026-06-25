import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

import 'helpers/pid_oict_test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('PID app flow', () {
    testWidgets(
      'loads stops, opens departures, and tracks a selected vehicle on the map',
      (tester) async {
        final receivedStops = <Stop>[];
        final receivedVehicleIds = <String>[];

        await tester.pumpWidget(
          PidOictTestApp(
            showMapTiles: false,
            vehicleMapRefreshInterval: Duration.zero,
            loadStops: () async => const [
              andelStop,
              staromestskaStop,
              technicalStop,
            ],
            loadDepartures: (stop) async {
              receivedStops.add(stop);

              return [repyDeparture(), motolDeparture()];
            },
            loadVehiclePosition: (vehicleId) async {
              receivedVehicleIds.add(vehicleId);

              return andelVehiclePosition(vehicleId: 'vehicle-from-api');
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('PID zastávky'), findsOneWidget);
        expect(find.text('Andel'), findsOneWidget);
        expect(find.text('Staromestska'), findsOneWidget);
        expect(find.text('hr.VUSC Praha'), findsNothing);

        await tester.tap(find.text('Andel'));
        await tester.pumpAndSettle();

        expect(receivedStops, hasLength(1));
        expect(receivedStops.single.id, andelStop.id);
        expect(find.text('Sidliste Repy'), findsOneWidget);
        expect(find.text('Nemocnice Motol'), findsOneWidget);

        await tester.tap(find.text('Sidliste Repy'));
        await tester.pumpAndSettle();

        expect(receivedVehicleIds, ['service-3-1001']);
        expect(find.text('10 – Sidliste Repy'), findsWidgets);
        expect(find.textContaining('vehicle-from-api'), findsNothing);
        expect(
          find.byKey(const ValueKey('vehicle-map-marker')),
          findsOneWidget,
        );

        await tester.tap(find.byTooltip('Zpět na odjezdy'));
        await tester.pumpAndSettle();

        expect(find.text('Sidliste Repy'), findsOneWidget);
      },
    );

    testWidgets('does not expose tracking when a departure has no vehicleId', (
      tester,
    ) async {
      var vehiclePositionWasRequested = false;

      await tester.pumpWidget(
        PidOictTestApp(
          showMapTiles: false,
          loadStops: () async => const [andelStop],
          loadDepartures: (_) async => [
            motolDeparture(gtfsTripId: 'trip-without-vehicle'),
          ],
          loadVehiclePosition: (_) async {
            vehiclePositionWasRequested = true;

            return andelVehiclePosition();
          },
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Andel'));
      await tester.pumpAndSettle();

      expect(find.text('Nemocnice Motol'), findsOneWidget);
      await tester.tap(find.text('Nemocnice Motol'));
      await tester.pumpAndSettle();

      expect(vehiclePositionWasRequested, isFalse);
    });

    testWidgets(
      'keeps the last vehicle position visible when a polling refresh fails',
      (tester) async {
        var vehiclePositionCalls = 0;

        await tester.pumpWidget(
          PidOictTestApp(
            showMapTiles: false,
            vehicleMapRefreshInterval: const Duration(milliseconds: 50),
            loadStops: () async => const [andelStop],
            loadDepartures: (_) async => [repyDeparture()],
            loadVehiclePosition: (_) async {
              vehiclePositionCalls++;
              if (vehiclePositionCalls == 1) {
                return andelVehiclePosition(vehicleId: 'vehicle-before-stale');
              }

              throw const AppException(
                type: AppExceptionType.timeout,
                message: 'Timeout.',
              );
            },
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Andel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sidliste Repy'));
        await tester.pumpAndSettle();

        expect(find.text('10 – Sidliste Repy'), findsWidgets);
        expect(find.textContaining('vehicle-before-stale'), findsNothing);
        expect(
          find.byKey(const ValueKey('vehicle-map-marker')),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 60));
        await tester.pump();
        await tester.pump();

        expect(vehiclePositionCalls, greaterThanOrEqualTo(2));
        expect(find.text('10 – Sidliste Repy'), findsWidgets);
        expect(find.textContaining('vehicle-before-stale'), findsNothing);
        expect(
          find.byKey(const ValueKey('vehicle-map-marker')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Zobrazuji poslední známou polohu. '
            'Golemio API neodpovědělo včas. Zkuste to prosím znovu.',
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  });
}
