import '../models/cached_stops.dart';

abstract interface class StopsCacheDataSource {
  Future<CachedStops?> read();

  Future<void> write(CachedStops cache);

  Future<void> clear();
}
