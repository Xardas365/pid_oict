import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';
import 'stop.dart';

const double logicalStopGroupProximityThresholdMeters = 500;
const double _logicalStopSpatialBucketSizeDegrees = 0.01;

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
    ..sort(_compareStopsForClustering);
  final disjointSet = _DisjointSet(sortedStops.length);
  final firstIndexByParentStation = <String, int>{};
  final indexesByNormalizedName = <String, List<int>>{};

  for (var index = 0; index < sortedStops.length; index++) {
    final stop = sortedStops[index];
    final parentStationId = stop.parentStationId?.trim();

    if (parentStationId != null && parentStationId.isNotEmpty) {
      final existingIndex = firstIndexByParentStation[parentStationId];
      if (existingIndex == null) {
        firstIndexByParentStation[parentStationId] = index;
      } else {
        disjointSet.union(existingIndex, index);
      }
    }

    indexesByNormalizedName
        .putIfAbsent(normalizeStopGroupName(stop.name), () => <int>[])
        .add(index);
  }

  for (final indexes in indexesByNormalizedName.values) {
    _unionSpatiallyCloseStops(sortedStops, indexes, disjointSet);
  }

  final stopsByRoot = <int, List<Stop>>{};
  for (var index = 0; index < sortedStops.length; index++) {
    final root = disjointSet.find(index);
    stopsByRoot.putIfAbsent(root, () => <Stop>[]).add(sortedStops[index]);
  }

  final clusters =
      stopsByRoot.values
          .map((clusterStops) {
            final sortedClusterStops = clusterStops.toList(growable: false)
              ..sort((first, second) => first.id.compareTo(second.id));

            return _StopGroupCluster(
              List<Stop>.unmodifiable(sortedClusterStops),
            );
          })
          .toList(growable: false)
        ..sort((first, second) {
          return _compareStopsForClustering(
            first.stops.first,
            second.stops.first,
          );
        });

  return clusters;
}

int _compareStopsForClustering(Stop first, Stop second) {
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
}

void _unionSpatiallyCloseStops(
  List<Stop> stops,
  List<int> indexes,
  _DisjointSet disjointSet,
) {
  final indexesByBucket = <_SpatialBucketKey, List<int>>{};

  for (final index in indexes) {
    final stop = stops[index];
    if (!_hasValidCoordinates(stop)) {
      continue;
    }

    final bucket = _SpatialBucketKey.fromStop(stop);
    for (final neighborBucket in bucket.neighbors) {
      final candidateIndexes = indexesByBucket[neighborBucket];
      if (candidateIndexes == null) {
        continue;
      }

      for (final candidateIndex in candidateIndexes) {
        if (_distanceMeters(stop, stops[candidateIndex]) <=
            logicalStopGroupProximityThresholdMeters) {
          disjointSet.union(index, candidateIndex);
        }
      }
    }

    indexesByBucket.putIfAbsent(bucket, () => <int>[]).add(index);
  }
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
}

@immutable
class _SpatialBucketKey {
  const _SpatialBucketKey(this.latitude, this.longitude);

  factory _SpatialBucketKey.fromStop(Stop stop) {
    return _SpatialBucketKey(
      (stop.latitude! / _logicalStopSpatialBucketSizeDegrees).floor(),
      (stop.longitude! / _logicalStopSpatialBucketSizeDegrees).floor(),
    );
  }

  final int latitude;
  final int longitude;

  Iterable<_SpatialBucketKey> get neighbors sync* {
    for (var latitudeOffset = -1; latitudeOffset <= 1; latitudeOffset++) {
      for (var longitudeOffset = -1; longitudeOffset <= 1; longitudeOffset++) {
        yield _SpatialBucketKey(
          latitude + latitudeOffset,
          longitude + longitudeOffset,
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _SpatialBucketKey &&
            latitude == other.latitude &&
            longitude == other.longitude;
  }

  @override
  int get hashCode {
    return Object.hash(latitude, longitude);
  }
}

class _DisjointSet {
  _DisjointSet(int size)
    : _parents = List<int>.generate(size, (index) => index),
      _ranks = List<int>.filled(size, 0);

  final List<int> _parents;
  final List<int> _ranks;

  int find(int index) {
    final parent = _parents[index];
    if (parent == index) {
      return index;
    }

    final root = find(parent);
    _parents[index] = root;
    return root;
  }

  void union(int first, int second) {
    final firstRoot = find(first);
    final secondRoot = find(second);
    if (firstRoot == secondRoot) {
      return;
    }

    final firstRank = _ranks[firstRoot];
    final secondRank = _ranks[secondRoot];
    if (firstRank < secondRank) {
      _parents[firstRoot] = secondRoot;
      return;
    }

    if (firstRank > secondRank) {
      _parents[secondRoot] = firstRoot;
      return;
    }

    _parents[secondRoot] = firstRoot;
    _ranks[firstRoot] = firstRank + 1;
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
