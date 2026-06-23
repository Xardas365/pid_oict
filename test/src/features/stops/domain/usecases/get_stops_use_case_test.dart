import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/repositories/stops_repository.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/usecases/get_stops_use_case.dart';

void main() {
  test('GetStopsUseCase delegates to StopsRepository', () async {
    final stops = [
      const Stop(id: 'U1', name: 'Andel', latitude: 50.071, longitude: 14.404),
    ];
    final repository = _FakeStopsRepository(stops);
    final useCase = GetStopsUseCase(repository);

    final result = await useCase();

    expect(result, stops);
    expect(repository.callCount, 1);
  });
}

class _FakeStopsRepository implements StopsRepository {
  _FakeStopsRepository(this._stops);

  final List<Stop> _stops;
  var callCount = 0;

  @override
  Future<List<Stop>> fetchStops() async {
    callCount++;
    return _stops;
  }
}
