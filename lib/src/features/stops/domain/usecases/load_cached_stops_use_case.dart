import '../repositories/stops_cache_repository.dart';
import '../stops_cache_snapshot.dart';

class LoadCachedStopsUseCase {
  const LoadCachedStopsUseCase(this._repository);

  final StopsCacheRepository _repository;

  Future<StopsCacheSnapshot?> call() async {
    try {
      return await _repository.read();
    } on Object {
      return null;
    }
  }
}
