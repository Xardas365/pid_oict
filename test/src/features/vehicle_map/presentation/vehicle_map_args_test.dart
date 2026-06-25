import 'package:flutter_test/flutter_test.dart';
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
  });
}
