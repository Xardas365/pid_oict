import '../../../stops/domain/stop.dart';
import '../departure.dart';
import '../repositories/departures_repository.dart';

class GetDeparturesForStopUseCase {
  const GetDeparturesForStopUseCase(this._repository);

  final DeparturesRepository _repository;

  Future<List<Departure>> call(Stop stop) {
    return _repository.fetchDeparturesForStop(stop);
  }
}
