import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/data/datasources/vehicle_positions_remote_data_source.dart';

void main() {
  group('VehiclePositionRequest', () {
    test('builds public vehicle position endpoint with scopes info', () {
      final request = VehiclePositionRequest(vehicleId: ' service-3-1001 ');

      expect(request.vehicleId, 'service-3-1001');
      expect(request.path, '/v2/public/vehiclepositions/service-3-1001');
      expect(request.queryParameters, {'scopes': 'info'});
    });

    test('encodes vehicle id as one path segment', () {
      final request = VehiclePositionRequest(vehicleId: 'service/with slash');

      expect(
        request.path,
        '/v2/public/vehiclepositions/service%2Fwith%20slash',
      );
    });
  });
}
