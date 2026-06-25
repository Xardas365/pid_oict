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
    this.parentStationNamesById = const <String, String>{},
  });

  final List<Stop> stops;
  final int limit;
  final int offset;
  final int rawReturnedCount;
  final bool hasMore;
  final Map<String, String> parentStationNamesById;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopsPage &&
            iterableEquals(stops, other.stops) &&
            limit == other.limit &&
            offset == other.offset &&
            rawReturnedCount == other.rawReturnedCount &&
            hasMore == other.hasMore &&
            _mapEquals(parentStationNamesById, other.parentStationNamesById);
  }

  @override
  int get hashCode {
    return Object.hash(
      iterableHash(stops),
      limit,
      offset,
      rawReturnedCount,
      hasMore,
      _mapHash(parentStationNamesById),
    );
  }
}

bool _mapEquals(Map<String, String> first, Map<String, String> second) {
  if (identical(first, second)) {
    return true;
  }

  if (first.length != second.length) {
    return false;
  }

  for (final entry in first.entries) {
    if (second[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

int _mapHash(Map<String, String> values) {
  final entries = values.entries.toList(growable: false)
    ..sort((first, second) => first.key.compareTo(second.key));

  return Object.hashAll(
    entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
