import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';
import 'stop.dart';

@immutable
class StopsPage {
  const StopsPage({
    required this.stops,
    required this.limit,
    required this.offset,
    required this.rawReturnedCount,
    required this.hasMore,
  });

  final List<Stop> stops;
  final int limit;
  final int offset;
  final int rawReturnedCount;
  final bool hasMore;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopsPage &&
            iterableEquals(stops, other.stops) &&
            limit == other.limit &&
            offset == other.offset &&
            rawReturnedCount == other.rawReturnedCount &&
            hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    return Object.hash(
      iterableHash(stops),
      limit,
      offset,
      rawReturnedCount,
      hasMore,
    );
  }
}
