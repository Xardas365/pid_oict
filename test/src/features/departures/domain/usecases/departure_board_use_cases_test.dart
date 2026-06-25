import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/repositories/departures_repository.dart';
import 'package:pid_oict/src/features/departures/domain/usecases/load_departure_board_use_case.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('departure board use cases', () {
    final stop = StopGroup.single(const Stop(id: 'U1', name: 'Andel'));
    final departures = [
      Departure(
        routeShortName: '9',
        headsign: 'Spojovaci',
        departureTime: DateTime.utc(2026, 1, 1, 12),
      ),
    ];

    test('LoadDepartureBoardUseCase delegates selected stop', () async {
      final repository = _FakeDeparturesRepository(departures);
      final useCase = LoadDepartureBoardUseCase(repository);

      final result = await useCase(stop);

      expect(result, departures);
      expect(repository.receivedStops, [stop]);
    });
  });
}

class _FakeDeparturesRepository implements DeparturesRepository {
  _FakeDeparturesRepository(this._departures);

  final List<Departure> _departures;
  final receivedStops = <StopGroup>[];

  @override
  Future<List<Departure>> fetchDeparturesForStop(StopGroup stop) async {
    receivedStops.add(stop);
    return _departures;
  }
}
