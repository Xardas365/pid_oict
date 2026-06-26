import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';
import 'stop.dart';

const double logicalStopGroupProximityThresholdMeters = 500;

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
    this.parentStationIds = const <String>[],
    this.zoneId,
    this.zoneIds = const <String>[],
    this.legacyGroupIds = const <String>[],
  });

  factory StopGroup.single(Stop stop) {
    return _buildStopGroup(stopGroupKey(stop), [stop]);
  }

  final String id;
  final String name;
  final String? parentStationId;
  final List<String> parentStationIds;
  final String? zoneId;
  final List<String> zoneIds;
  final double latitude;
  final double longitude;
  final List<Stop> stops;
  final List<String> stopIds;
  final List<String> platformCodes;
  final List<String> legacyGroupIds;

  int get stopCount => stops.length;

  Stop get representativeStop => stops.first;

  bool matchesSavedGroupId(String groupId) {
    final normalizedGroupId = groupId.trim();
    return id == normalizedGroupId ||
        legacyGroupIds.contains(normalizedGroupId);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopGroup &&
            id == other.id &&
            name == other.name &&
            parentStationId == other.parentStationId &&
            iterableEquals(parentStationIds, other.parentStationIds) &&
            zoneId == other.zoneId &&
            iterableEquals(zoneIds, other.zoneIds) &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            iterableEquals(stops, other.stops) &&
            iterableEquals(stopIds, other.stopIds) &&
            iterableEquals(platformCodes, other.platformCodes) &&
            iterableEquals(legacyGroupIds, other.legacyGroupIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      parentStationId,
      iterableHash(parentStationIds),
      zoneId,
      iterableHash(zoneIds),
      latitude,
      longitude,
      iterableHash(stops),
      iterableHash(stopIds),
      iterableHash(platformCodes),
      iterableHash(legacyGroupIds),
    );
  }
}

List<StopGroup> groupStops(Iterable<Stop> stops) {
  final clusters = _clusterLogicalStops(stops);
  final legacyGroupCounts = _legacyGroupCounts(clusters);
  final groups =
      clusters
          .map((cluster) {
            return _buildStopGroup(
              _logicalGroupId(cluster.stops, legacyGroupCounts),
              cluster.stops,
            );
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
  final zoneIds = _sortedUniqueStrings(sortedStops.map((stop) => stop.zoneId));
  final parentStationIds = _sortedUniqueStrings(
    sortedStops.map((stop) => stop.parentStationId),
  );

  return StopGroup(
    id: id,
    name: _displayName(sortedStops),
    parentStationId: _parentStationId(sortedStops),
    parentStationIds: parentStationIds,
    zoneId: _mostCommonString(sortedStops.map((stop) => stop.zoneId)),
    zoneIds: zoneIds,
    latitude: representativeStop.latitude ?? 0,
    longitude: representativeStop.longitude ?? 0,
    stops: List<Stop>.unmodifiable(sortedStops),
    stopIds: List<String>.unmodifiable(
      sortedStops.map((stop) => stop.id).where((id) => id.trim().isNotEmpty),
    ),
    platformCodes: _platformCodes(sortedStops),
    legacyGroupIds: List<String>.unmodifiable(_legacyGroupIds(sortedStops)),
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

List<_StopGroupCluster> _clusterLogicalStops(Iterable<Stop> stops) {
  final sortedStops = stops.toList(growable: false)
    ..sort((first, second) {
      final nameComparison = normalizeStopGroupName(
        first.name,
      ).compareTo(normalizeStopGroupName(second.name));
      if (nameComparison != 0) {
        return nameComparison;
      }

      final groupKeyComparison = stopGroupKey(
        first,
      ).compareTo(stopGroupKey(second));
      if (groupKeyComparison != 0) {
        return groupKeyComparison;
      }

      return first.id.compareTo(second.id);
    });
  final clusters = <_StopGroupCluster>[];

  for (final stop in sortedStops) {
    final clusterIndex = clusters.indexWhere((cluster) {
      return cluster.canAccept(stop);
    });

    if (clusterIndex == -1) {
      clusters.add(_StopGroupCluster([stop]));
      continue;
    }

    clusters[clusterIndex] = clusters[clusterIndex].withStop(stop);
  }

  return clusters;
}

Map<String, int> _legacyGroupCounts(List<_StopGroupCluster> clusters) {
  final counts = <String, int>{};

  for (final cluster in clusters) {
    for (final legacyGroupId in _legacyGroupIds(cluster.stops)) {
      counts[legacyGroupId] = (counts[legacyGroupId] ?? 0) + 1;
    }
  }

  return counts;
}

String _logicalGroupId(
  List<Stop> stops,
  Map<String, int> legacyGroupCounts,
) {
  final sortedStops = stops.toList(growable: false)
    ..sort((first, second) => first.id.compareTo(second.id));
  final legacyGroupIds = _legacyGroupIds(sortedStops);

  if (legacyGroupIds.length == 1 &&
      (legacyGroupCounts[legacyGroupIds.single] ?? 0) == 1) {
    return legacyGroupIds.single;
  }

  final normalizedName = normalizeStopGroupName(_displayName(sortedStops));
  if (legacyGroupIds.length > 1) {
    return 'logical:$normalizedName:${legacyGroupIds.first}';
  }

  return 'logical:$normalizedName:${sortedStops.first.id}';
}

List<String> _legacyGroupIds(List<Stop> stops) {
  final groupIds = <String>{};

  for (final stop in stops) {
    groupIds.add(stopGroupKey(stop));
  }

  final sortedGroupIds = groupIds.toList(growable: false)..sort();
  return List<String>.unmodifiable(sortedGroupIds);
}

List<String> _sortedUniqueStrings(Iterable<String?> values) {
  final strings = <String>{};

  for (final value in values) {
    final trimmedValue = value?.trim();
    if (trimmedValue != null && trimmedValue.isNotEmpty) {
      strings.add(trimmedValue);
    }
  }

  final sortedStrings = strings.toList(growable: false)
    ..sort(
      (first, second) => first.toLowerCase().compareTo(
        second.toLowerCase(),
      ),
    );

  return List<String>.unmodifiable(sortedStrings);
}

class _StopGroupCluster {
  const _StopGroupCluster(this.stops);

  final List<Stop> stops;

  _StopGroupCluster withStop(Stop stop) {
    return _StopGroupCluster(List<Stop>.unmodifiable([...stops, stop]));
  }

  bool canAccept(Stop stop) {
    return _sharesParentStation(stop) ||
        (_sharesNormalizedName(stop) && _isSpatiallyClose(stop));
  }

  bool _sharesParentStation(Stop stop) {
    final parentStationId = stop.parentStationId?.trim();
    if (parentStationId == null || parentStationId.isEmpty) {
      return false;
    }

    return stops.any((existingStop) {
      return existingStop.parentStationId?.trim() == parentStationId;
    });
  }

  bool _sharesNormalizedName(Stop stop) {
    final normalizedName = normalizeStopGroupName(stop.name);

    return stops.any((existingStop) {
      return normalizeStopGroupName(existingStop.name) == normalizedName;
    });
  }

  bool _isSpatiallyClose(Stop stop) {
    if (!_hasValidCoordinates(stop)) {
      return false;
    }

    return stops.any((existingStop) {
      return _hasValidCoordinates(existingStop) &&
          _distanceMeters(stop, existingStop) <=
              logicalStopGroupProximityThresholdMeters;
    });
  }
}

bool _hasValidCoordinates(Stop stop) {
  final latitude = stop.latitude;
  final longitude = stop.longitude;

  return latitude != null &&
      longitude != null &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

double _distanceMeters(Stop first, Stop second) {
  const earthRadiusMeters = 6371000.0;
  final firstLatitude = _degreesToRadians(first.latitude!);
  final secondLatitude = _degreesToRadians(second.latitude!);
  final latitudeDelta = _degreesToRadians(second.latitude! - first.latitude!);
  final longitudeDelta = _degreesToRadians(
    second.longitude! - first.longitude!,
  );
  final haversine =
      math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.sin(longitudeDelta / 2) *
          math.sin(longitudeDelta / 2);
  final centralAngle =
      2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

  return earthRadiusMeters * centralAngle;
}

double _degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
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
