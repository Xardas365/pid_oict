import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_screen.dart';

import '../../../test_localized_app.dart';

void main() {
  group('VehicleMapScreen', () {
    testWidgets('shows map marker and last update after position loads', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedTestApp(
          home: VehicleMapScreen(
            gtfsTripId: 'trip-22-123',
            refreshInterval: Duration.zero,
            showMapTiles: false,
            loadVehiclePosition: (_) async => VehiclePosition(
              vehicleId: 'vehicle-123',
              latitude: 50.0755,
              longitude: 14.4378,
              lastUpdated: DateTime(2026, 6, 22, 10, 20),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Poloha vozidla'), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(find.text('Poslední aktualizace 10:20:00'), findsOneWidget);
      expect(
        find.text('Mapová data (c) přispěvatelé OpenStreetMap'),
        findsOneWidget,
      );
    });

    testWidgets('shows no-position state for invalid data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedTestApp(
          home: VehicleMapScreen(
            gtfsTripId: 'trip-22-123',
            refreshInterval: Duration.zero,
            showMapTiles: false,
            loadVehiclePosition: (_) async => throw const AppException(
              type: AppExceptionType.invalidData,
              message: 'No position.',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Aktuální poloha vozidla není dostupná.'),
        findsOneWidget,
      );
    });

    testWidgets('shows initial error and retries loading', (
      WidgetTester tester,
    ) async {
      var attempts = 0;

      await tester.pumpWidget(
        localizedTestApp(
          home: VehicleMapScreen(
            gtfsTripId: 'trip-22-123',
            refreshInterval: Duration.zero,
            showMapTiles: false,
            loadVehiclePosition: (_) async {
              attempts += 1;
              if (attempts == 1) {
                throw const AppException(
                  type: AppExceptionType.network,
                  message: 'Network error.',
                );
              }

              return const VehiclePosition(
                vehicleId: 'vehicle-123',
                latitude: 50.0755,
                longitude: 14.4378,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nepodařilo se připojit ke Golemio API. '
          'Zkontrolujte připojení k internetu.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Zkusit znovu'));
      await tester.pumpAndSettle();

      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(attempts, 2);
    });

    testWidgets('keeps last known position when periodic refresh fails', (
      WidgetTester tester,
    ) async {
      var attempts = 0;

      await tester.pumpWidget(
        localizedTestApp(
          home: VehicleMapScreen(
            gtfsTripId: 'trip-22-123',
            refreshInterval: const Duration(seconds: 1),
            showMapTiles: false,
            loadVehiclePosition: (_) async {
              attempts += 1;
              if (attempts > 1) {
                throw const AppException(
                  type: AppExceptionType.timeout,
                  message: 'Timeout.',
                );
              }

              return const VehiclePosition(
                vehicleId: 'vehicle-123',
                latitude: 50.0755,
                longitude: 14.4378,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(attempts, 1);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(attempts, 2);
      expect(find.text('Vozidlo vehicle-123'), findsOneWidget);
      expect(
        find.text(
          'Zobrazuji poslední známou polohu. '
          'Golemio API neodpovědělo včas. Zkuste to prosím znovu.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
