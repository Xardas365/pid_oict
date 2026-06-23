import 'package:pid_oict/src/features/stops/data/datasources/stops_cache_data_source.dart';
import 'package:pid_oict/src/features/stops/data/models/cached_stops.dart';

class InMemoryStopsCacheDataSource implements StopsCacheDataSource {
  CachedStops? _cache;

  @override
  Future<CachedStops?> read() async {
    return _cache;
  }

  @override
  Future<void> write(CachedStops cache) async {
    _cache = cache;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}
