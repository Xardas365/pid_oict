import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';

void main() {
  group('VehicleId', () {
    test('normalizes surrounding whitespace', () {
      expect(VehicleId(' service-3-1001 ').value, 'service-3-1001');
    });

    test('tryParse returns null for missing or blank values', () {
      expect(VehicleId.tryParse(null), isNull);
      expect(VehicleId.tryParse('   '), isNull);
    });

    test('throws for blank constructor input', () {
      expect(() => VehicleId('   '), throwsArgumentError);
    });

    test('exposes normalized value', () {
      expect(VehicleId(' service-3-1001 ').value, 'service-3-1001');
    });
  });
}
