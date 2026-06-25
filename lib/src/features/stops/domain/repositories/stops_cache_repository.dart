import '../stops_cache_snapshot.dart';

abstract interface class StopsCacheRepository {
  Future<StopsCacheSnapshot?> read();

  Future<void> write(StopsCacheSnapshot cache);

  Future<void> clear();
}
