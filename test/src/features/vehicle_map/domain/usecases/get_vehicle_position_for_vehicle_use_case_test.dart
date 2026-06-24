import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  test('GetVehiclePositionForVehicleUseCase delegates vehicle id', () async {
    final position = VehiclePosition(
      vehicleId: 'service-3-1001',
      latitude: 50.0755,
      longitude: 14.4378,
    );
    final repository = _FakeVehiclePositionRepository(position);
    final useCase = GetVehiclePositionForVehicleUseCase(repository);

    final result = await useCase('service-3-1001');

    expect(result, same(position));
    expect(repository.receivedVehicleId, 'service-3-1001');
  });
}

class _FakeVehiclePositionRepository implements VehiclePositionRepository {
  _FakeVehiclePositionRepository(this._position);

  final VehiclePosition _position;
  String? receivedVehicleId;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String vehicleId) async {
    receivedVehicleId = vehicleId;
    return _position;
  }
}
