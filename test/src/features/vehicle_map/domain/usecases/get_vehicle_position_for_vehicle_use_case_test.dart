import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_vehicle_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_id.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  test('GetVehiclePositionForVehicleUseCase delegates vehicle id', () async {
    const position = VehiclePosition(
      vehicleId: 'service-3-1001',
      latitude: 50.0755,
      longitude: 14.4378,
    );
    final repository = _FakeVehiclePositionRepository(position);
    final useCase = GetVehiclePositionForVehicleUseCase(repository);

    final result = await useCase(VehicleId('service-3-1001'));

    expect(result, same(position));
    expect(repository.receivedVehicleId?.value, 'service-3-1001');
  });
}

class _FakeVehiclePositionRepository implements VehiclePositionRepository {
  _FakeVehiclePositionRepository(this._position);

  final VehiclePosition _position;
  VehicleId? receivedVehicleId;

  @override
  Future<VehiclePosition> fetchVehiclePosition(VehicleId vehicleId) async {
    receivedVehicleId = vehicleId;
    return _position;
  }
}
