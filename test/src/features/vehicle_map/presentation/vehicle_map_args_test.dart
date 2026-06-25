import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/presentation/vehicle_map_args.dart';

void main() {
  group('VehicleMapArgs', () {
    test('wraps a valid typed vehicle id', () {
      final args = VehicleMapArgs(vehicleId: VehicleId('service-3-1001'));

      expect(args.vehicleId.value, 'service-3-1001');
    });

    test('parses and normalizes raw vehicle id at navigation boundary', () {
      final args = VehicleMapArgs.tryParseVehicleId(' service-3-1001 ');

      expect(args?.vehicleId.value, 'service-3-1001');
    });

    test('rejects missing or empty vehicle id safely', () {
      expect(VehicleMapArgs.tryParseVehicleId(null), isNull);
      expect(VehicleMapArgs.tryParseVehicleId('   '), isNull);
    });

    test('builds route display context from a trackable departure', () {
      final args = VehicleMapArgs.fromDeparture(
        Departure(
          routeShortName: ' 10 ',
          routeType: 'tram',
          headsign: ' Sidliste Repy ',
          departureTime: DateTime(2026, 6, 22, 10, 15),
          vehicleId: ' service-3-1001 ',
        ),
      );

      expect(args?.vehicleId.value, 'service-3-1001');
      expect(args?.routeShortName, '10');
      expect(args?.headsign, 'Sidliste Repy');
      expect(args?.routeType, 'tram');
      expect(args?.lineType, PidLineType.tram);
      expect(args?.title, '10 – Sidliste Repy');
    });

    test('does not build args from an untrackable departure', () {
      final args = VehicleMapArgs.fromDeparture(
        Departure(
          routeShortName: 'A',
          headsign: 'Nemocnice Motol',
          departureTime: DateTime(2026, 6, 22, 10, 15),
        ),
      );

      expect(args, isNull);
    });

    test('equality includes display context', () {
      final first = VehicleMapArgs(
        vehicleId: VehicleId('service-3-1001'),
        routeShortName: '10',
        headsign: 'Sidliste Repy',
        routeType: 'tram',
        lineType: PidLineType.tram,
      );
      final same = VehicleMapArgs(
        vehicleId: VehicleId('service-3-1001'),
        routeShortName: '10',
        headsign: 'Sidliste Repy',
        routeType: 'tram',
        lineType: PidLineType.tram,
      );
      final differentContext = VehicleMapArgs(
        vehicleId: VehicleId('service-3-1001'),
        routeShortName: '22',
        headsign: 'Bila Hora',
      );

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(differentContext));
    });
  });
}
