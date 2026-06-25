import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/data/models/departure_dto.dart';
import 'package:pid_oict/src/features/stops/data/models/stop_dto.dart';
import 'package:pid_oict/src/features/vehicle_map/data/models/vehicle_position_dto.dart';

import '../../helpers/json_fixture.dart';

void main() {
  group('Golemio API contract fixtures', () {
    test(
      'stops parser loads valid public stops and skips invalid records',
      () async {
        final fixture = await loadJsonFixture(
          'golemio/gtfs_stops_feature_collection.json',
        );

        final result = StopDto.parseWithDiagnostics(fixture);

        expect(result.diagnostics.rawCount, 3);
        expect(result.diagnostics.parsedCount, 2);
        expect(result.diagnostics.skippedCount, 1);
        expect(
          result.diagnostics.skipReasons.single.reason,
          'missing display name',
        );
        expect(result.items.map((stop) => stop.id), ['U118Z101P', 'U299Z102P']);
        expect(result.items.first.name, 'Flora');
        expect(result.items.first.latitude, 50.07827);
        expect(result.items.first.longitude, 14.4633);
        expect(result.items.first.locationType, 0);
        expect(result.items.first.zoneId, 'P');
      },
    );

    test(
      'departure board parser reads tracked and untracked departures',
      () async {
        final fixture = await loadJsonFixture(
          'golemio/departure_board_response.json',
        );

        final result = DepartureDto.parseWithDiagnostics(fixture);

        expect(result.diagnostics.rawCount, 3);
        expect(result.diagnostics.parsedCount, 2);
        expect(result.diagnostics.skippedCount, 1);
        expect(
          result.diagnostics.skipReasons.single.reason,
          'missing or invalid departure time',
        );

        final tracked = result.items.first;
        expect(tracked.routeShortName, '10');
        expect(tracked.routeType, 'tram');
        expect(tracked.headsign, 'Sidliste Repy');
        expect(
          tracked.departureTime,
          DateTime.parse('2026-06-22T10:15:30+02:00'),
        );
        expect(tracked.delaySeconds, 90);
        expect(tracked.platform, 'A');
        expect(tracked.stopId, 'U118Z101P');
        expect(tracked.gtfsTripId, '10_1234_260622');
        expect(tracked.vehicleId, 'service-3-1001');
        expect(tracked.isWheelchairAccessible, isTrue);

        final untracked = result.items.last.toDomain();
        expect(untracked.routeShortName, '136');
        expect(untracked.vehicleId, isNull);
      },
    );

    test(
      'vehicle position parser reads public response GPS and metadata',
      () async {
        final fixture = await loadJsonFixture(
          'golemio/vehicle_position_public_response.json',
        );

        final result = VehiclePositionDto.parseWithDiagnostics(
          fixture,
          fallbackVehicleId: 'service-3-1001',
        );

        expect(result.diagnostics.rawCount, 1);
        expect(result.diagnostics.parsedCount, 1);
        expect(result.diagnostics.skippedCount, 0);

        final position = result.items.single;
        expect(position.vehicleId, 'service-3-1001');
        expect(position.latitude, 50.109318);
        expect(position.longitude, 14.441252);
        expect(position.bearing, 45);
        expect(
          position.lastUpdated,
          DateTime.parse('2023-12-06T12:00:00+01:00'),
        );
      },
    );

    test('vehicle position parser tolerates missing optional fields', () async {
      final fixture = await loadJsonFixture(
        'golemio/vehicle_position_minimal_response.json',
      );

      final result = VehiclePositionDto.parseWithDiagnostics(fixture);

      expect(result.diagnostics.rawCount, 1);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 0);

      final position = result.items.single;
      expect(position.vehicleId, 'service-3-1001');
      expect(position.latitude, 50.0755);
      expect(position.longitude, 14.4378);
      expect(position.bearing, isNull);
      expect(position.lastUpdated, isNull);
    });
  });
}
