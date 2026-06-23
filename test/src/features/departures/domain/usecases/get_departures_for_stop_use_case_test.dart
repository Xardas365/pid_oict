import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/get_departures_for_stop_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';

void main() {
  test('GetDeparturesForStopUseCase delegates selected stop', () async {
    const stop = Stop(id: 'U1', name: 'Andel');
    final departures = [
      Departure(
        routeShortName: '9',
        headsign: 'Spojovaci',
        departureTime: DateTime.utc(2026, 1, 1, 12),
      ),
    ];
    final repository = _FakeDeparturesRepository(departures);
    final useCase = GetDeparturesForStopUseCase(repository);

    final result = await useCase(stop);

    expect(result, departures);
    expect(repository.receivedStop, stop);
  });
}

class _FakeDeparturesRepository implements DeparturesRepository {
  _FakeDeparturesRepository(this._departures);

  final List<Departure> _departures;
  Stop? receivedStop;

  @override
  Future<List<Departure>> fetchDeparturesForStop(Stop stop) async {
    receivedStop = stop;
    return _departures;
  }
}
