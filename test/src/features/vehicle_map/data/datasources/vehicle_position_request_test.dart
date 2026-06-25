import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';

void main() {
  group('VehiclePositionRequest', () {
    test('builds public vehicle position endpoint with repeated scopes', () {
      final request = VehiclePositionRequest(
        vehicleId: VehicleId(' service-3-1001 '),
      );

      expect(request.vehicleId.value, 'service-3-1001');
      expect(request.path, '/v2/public/vehiclepositions/service-3-1001');
      expect(
        request.queryParameters.entries.map(
          (entry) => (entry.key, entry.value),
        ),
        [
          ('scopes', 'info'),
          ('scopes', 'stop_times'),
          ('scopes', 'shapes'),
          ('scopes', 'vehicle_descriptor'),
        ],
      );
      expect(
        request.queryParameters.encoded,
        'scopes=info&scopes=stop_times&scopes=shapes&'
        'scopes=vehicle_descriptor',
      );
    });

    test('encodes vehicle id as one path segment', () {
      final request = VehiclePositionRequest(
        vehicleId: VehicleId('service/with slash'),
      );

      expect(
        request.path,
        '/v2/public/vehiclepositions/service%2Fwith%20slash',
      );
    });
  });
}
