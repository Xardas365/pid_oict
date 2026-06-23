import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/repositories/vehicle_position_repository.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/usecases/get_vehicle_position_for_trip_use_case.dart';
import 'package:pid_oict/src/features/vehicle_map/domain/vehicle_position.dart';

void main() {
  test('GetVehiclePositionForTripUseCase delegates GTFS trip id', () async {
    final position = VehiclePosition(
      vehicleId: 'vehicle-1',
      latitude: 50.0755,
      longitude: 14.4378,
      lastUpdated: DateTime.utc(2026, 1, 1, 12),
    );
    final repository = _FakeVehiclePositionRepository(position);
    final useCase = GetVehiclePositionForTripUseCase(repository);

    final result = await useCase('trip-1');

    expect(result, position);
    expect(repository.receivedGtfsTripId, 'trip-1');
  });
}

class _FakeVehiclePositionRepository implements VehiclePositionRepository {
  _FakeVehiclePositionRepository(this._position);

  final VehiclePosition _position;
  String? receivedGtfsTripId;

  @override
  Future<VehiclePosition> fetchVehiclePosition(String gtfsTripId) async {
    receivedGtfsTripId = gtfsTripId;
    return _position;
  }
}
