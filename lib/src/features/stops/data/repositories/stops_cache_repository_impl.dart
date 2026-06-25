import '../../domain/repositories/stops_cache_repository.dart';
import '../../domain/stops_cache_snapshot.dart';
import '../datasources/stops_cache_data_source.dart';
import '../models/cached_stops.dart';

class StopsCacheRepositoryImpl implements StopsCacheRepository {
  const StopsCacheRepositoryImpl(this._dataSource);

  final StopsCacheDataSource _dataSource;

  @override
  Future<StopsCacheSnapshot?> read() async {
    final cache = await _dataSource.read();
    if (cache == null) {
      return null;
    }

    return StopsCacheSnapshot(
      cachedAt: cache.cachedAt,
      stops: cache.stops,
      hasMore: cache.hasMore,
      nextOffset: cache.nextOffset,
    );
  }

  @override
  Future<void> write(StopsCacheSnapshot cache) {
    return _dataSource.write(
      CachedStops(
        cachedAt: cache.cachedAt,
        stops: cache.stops,
        hasMore: cache.hasMore,
        nextOffset: cache.nextOffset,
      ),
    );
  }

  @override
  Future<void> clear() {
    return _dataSource.clear();
  }
}
