import 'package:meta/meta.dart';

import '../../../core/utils/value_equality.dart';

@immutable
class Stop {
  const Stop({
    required this.id,
    required this.name,
    this.platformCode,
    this.zoneId,
    this.locationType,
    this.parentStationId,
    this.wheelchairBoarding,
    this.levelId,
    this.latitude,
    this.longitude,
    this.searchAliases = const <String>[],
  });

  final String id;
  final String name;
  final String? platformCode;
  final String? zoneId;
  final int? locationType;
  final String? parentStationId;
  final int? wheelchairBoarding;
  final String? levelId;
  final double? latitude;
  final double? longitude;
  final List<String> searchAliases;

  Stop withSearchAliases(Iterable<String> aliases) {
    final uniqueAliases = <String>{};

    for (final alias in aliases) {
      final trimmedAlias = alias.trim();
      if (trimmedAlias.isNotEmpty) {
        uniqueAliases.add(trimmedAlias);
      }
    }

    return Stop(
      id: id,
      name: name,
      platformCode: platformCode,
      zoneId: zoneId,
      locationType: locationType,
      parentStationId: parentStationId,
      wheelchairBoarding: wheelchairBoarding,
      levelId: levelId,
      latitude: latitude,
      longitude: longitude,
      searchAliases: List<String>.unmodifiable(uniqueAliases),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Stop &&
            id == other.id &&
            name == other.name &&
            platformCode == other.platformCode &&
            zoneId == other.zoneId &&
            locationType == other.locationType &&
            parentStationId == other.parentStationId &&
            wheelchairBoarding == other.wheelchairBoarding &&
            levelId == other.levelId &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            iterableEquals(searchAliases, other.searchAliases);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      platformCode,
      zoneId,
      locationType,
      parentStationId,
      wheelchairBoarding,
      levelId,
      latitude,
      longitude,
      iterableHash(searchAliases),
    );
  }
}
