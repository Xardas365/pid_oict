import '../../../stops/domain/stop_group.dart';
import '../departure.dart';
import '../repositories/departures_repository.dart';

class LoadDepartureBoardUseCase {
  const LoadDepartureBoardUseCase(this._repository);

  final DeparturesRepository _repository;

  Future<List<Departure>> call(StopGroup stop) {
    return _repository.fetchDeparturesForStop(stop);
  }
}
