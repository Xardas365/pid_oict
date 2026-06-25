import 'stop.dart';

const stopsCacheTtl = Duration(hours: 24);

class StopsCacheSnapshot {
  const StopsCacheSnapshot({
    required this.cachedAt,
    required this.stops,
    this.hasMore = false,
    this.nextOffset = 0,
  });

  final DateTime cachedAt;
  final List<Stop> stops;
  final bool hasMore;
  final int nextOffset;

  bool isFresh(DateTime now, {Duration ttl = stopsCacheTtl}) {
    return isStopsCacheFresh(this, now, ttl: ttl);
  }
}

bool isStopsCacheFresh(
  StopsCacheSnapshot? cache,
  DateTime now, {
  Duration ttl = stopsCacheTtl,
}) {
  if (cache == null) {
    return false;
  }

  final age = now.toUtc().difference(cache.cachedAt.toUtc());
  if (age.isNegative) {
    return true;
  }

  return age <= ttl;
}
