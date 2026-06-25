import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';
import 'stop.dart';

@immutable
class StopGroup {
  const StopGroup({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.stops,
    required this.stopIds,
    required this.platformCodes,
    this.parentStationId,
    this.zoneId,
  });

  factory StopGroup.single(Stop stop) {
    return _buildStopGroup(stopGroupKey(stop), [stop]);
  }

  final String id;
  final String name;
  final String? parentStationId;
  final String? zoneId;
  final double latitude;
  final double longitude;
  final List<Stop> stops;
  final List<String> stopIds;
  final List<String> platformCodes;

  int get stopCount => stops.length;

  Stop get representativeStop => stops.first;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopGroup &&
            id == other.id &&
            name == other.name &&
            parentStationId == other.parentStationId &&
            zoneId == other.zoneId &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            iterableEquals(stops, other.stops) &&
            iterableEquals(stopIds, other.stopIds) &&
            iterableEquals(platformCodes, other.platformCodes);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      parentStationId,
      zoneId,
      latitude,
      longitude,
      iterableHash(stops),
      iterableHash(stopIds),
      iterableHash(platformCodes),
    );
  }
}

List<StopGroup> groupStops(Iterable<Stop> stops) {
  final groupedStops = <String, List<Stop>>{};

  for (final stop in stops) {
    final key = stopGroupKey(stop);
    groupedStops.putIfAbsent(key, () => <Stop>[]).add(stop);
  }

  final groups =
      groupedStops.entries
          .map((entry) {
            return _buildStopGroup(entry.key, entry.value);
          })
          .toList(growable: false)
        ..sort(compareStopGroupsByPublicName);

  return List<StopGroup>.unmodifiable(groups);
}

String stopGroupKey(Stop stop) {
  final parentStationId = stop.parentStationId?.trim();
  if (parentStationId != null && parentStationId.isNotEmpty) {
    return parentStationId;
  }

  return 'name:${normalizeStopGroupName(stop.name)}';
}

String normalizeStopGroupName(String name) {
  return name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

int compareStopGroupsByPublicName(StopGroup first, StopGroup second) {
  final nameComparison = first.name.toLowerCase().compareTo(
    second.name.toLowerCase(),
  );
  if (nameComparison != 0) {
    return nameComparison;
  }

  return first.id.compareTo(second.id);
}

StopGroup _buildStopGroup(String id, List<Stop> stops) {
  final sortedStops = stops.toList(growable: false)
    ..sort((first, second) => first.id.compareTo(second.id));
  final representativeStop = _representativeStop(sortedStops);

  return StopGroup(
    id: id,
    name: _displayName(sortedStops),
    parentStationId: _parentStationId(sortedStops),
    zoneId: _mostCommonString(sortedStops.map((stop) => stop.zoneId)),
    latitude: representativeStop.latitude ?? 0,
    longitude: representativeStop.longitude ?? 0,
    stops: List<Stop>.unmodifiable(sortedStops),
    stopIds: List<String>.unmodifiable(
      sortedStops.map((stop) => stop.id).where((id) => id.trim().isNotEmpty),
    ),
    platformCodes: _platformCodes(sortedStops),
  );
}

Stop _representativeStop(List<Stop> sortedStops) {
  return sortedStops.firstWhere(
    (stop) => stop.latitude != null && stop.longitude != null,
    orElse: () => sortedStops.first,
  );
}

String _displayName(List<Stop> stops) {
  final countsByName = <String, ({String original, int count})>{};

  for (final stop in stops) {
    final normalizedName = normalizeStopGroupName(stop.name);
    if (normalizedName.isEmpty) {
      continue;
    }

    final current = countsByName[normalizedName];
    countsByName[normalizedName] = (
      original: current?.original ?? stop.name.trim(),
      count: (current?.count ?? 0) + 1,
    );
  }

  final names = countsByName.values.toList(growable: false)
    ..sort((first, second) {
      final countComparison = second.count.compareTo(first.count);
      if (countComparison != 0) {
        return countComparison;
      }

      return first.original.toLowerCase().compareTo(
        second.original.toLowerCase(),
      );
    });

  return names.first.original;
}

String? _parentStationId(List<Stop> stops) {
  return _mostCommonString(stops.map((stop) => stop.parentStationId));
}

String? _mostCommonString(Iterable<String?> values) {
  final counts = <String, int>{};

  for (final value in values) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      continue;
    }

    counts[trimmedValue] = (counts[trimmedValue] ?? 0) + 1;
  }

  if (counts.isEmpty) {
    return null;
  }

  final entries = counts.entries.toList(growable: false)
    ..sort((first, second) {
      final countComparison = second.value.compareTo(first.value);
      if (countComparison != 0) {
        return countComparison;
      }

      return first.key.toLowerCase().compareTo(second.key.toLowerCase());
    });

  return entries.first.key;
}

List<String> _platformCodes(List<Stop> stops) {
  final platformCodes = <String>{};

  for (final stop in stops) {
    final platformCode = stop.platformCode?.trim();
    if (platformCode != null && platformCode.isNotEmpty) {
      platformCodes.add(platformCode);
    }
  }

  final sortedPlatformCodes = platformCodes.toList(growable: false)
    ..sort(_comparePlatformCodes);

  return List<String>.unmodifiable(sortedPlatformCodes);
}

int _comparePlatformCodes(String first, String second) {
  final firstNumber = int.tryParse(first);
  final secondNumber = int.tryParse(second);

  if (firstNumber != null && secondNumber != null) {
    final numberComparison = firstNumber.compareTo(secondNumber);
    if (numberComparison != 0) {
      return numberComparison;
    }
  }

  return first.toLowerCase().compareTo(second.toLowerCase());
}
