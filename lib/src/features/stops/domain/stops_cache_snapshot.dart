import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';
import 'stop.dart';

const stopsCacheTtl = Duration(hours: 24);

@immutable
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopsCacheSnapshot &&
            cachedAt == other.cachedAt &&
            iterableEquals(stops, other.stops) &&
            hasMore == other.hasMore &&
            nextOffset == other.nextOffset;
  }

  @override
  int get hashCode {
    return Object.hash(cachedAt, iterableHash(stops), hasMore, nextOffset);
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
