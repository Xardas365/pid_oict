import '../repositories/stops_cache_repository.dart';
import '../stop.dart';
import '../stops_cache_snapshot.dart';

class SaveStopsCacheUseCase {
  const SaveStopsCacheUseCase(this._repository);

  final StopsCacheRepository _repository;

  Future<void> call({
    required DateTime cachedAt,
    required List<Stop> stops,
    required bool hasMore,
    required int nextOffset,
  }) async {
    if (stops.isEmpty) {
      return;
    }

    try {
      await _repository.write(
        StopsCacheSnapshot(
          cachedAt: cachedAt,
          stops: List<Stop>.unmodifiable(stops),
          hasMore: hasMore,
          nextOffset: nextOffset,
        ),
      );
    } on Object {
      // Cache persistence must not block live stop loading.
    }
  }
}
