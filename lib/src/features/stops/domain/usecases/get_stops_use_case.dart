import '../repositories/stops_repository.dart';
import '../stop.dart';

class GetStopsUseCase {
  const GetStopsUseCase(this._repository);

  final StopsRepository _repository;

  Future<List<Stop>> call() {
    return _repository.fetchStops();
  }
}
