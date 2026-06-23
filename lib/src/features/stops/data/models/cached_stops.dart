import '../../../../shared/utils/json_parsing.dart';
import '../../domain/stop.dart';

const stopsCacheSchemaVersion = 1;
const stopsCacheTtl = Duration(hours: 24);

class CachedStops {
  const CachedStops({
    required this.cachedAt,
    required this.stops,
    this.schemaVersion = stopsCacheSchemaVersion,
    this.hasMore = false,
    this.nextOffset = 0,
  });

  final int schemaVersion;
  final DateTime cachedAt;
  final List<Stop> stops;
  final bool hasMore;
  final int nextOffset;

  bool isFresh(DateTime now, {Duration ttl = stopsCacheTtl}) {
    return isStopsCacheFresh(this, now, ttl: ttl);
  }

  JsonMap toJson() {
    return {
      'schemaVersion': schemaVersion,
      'cachedAt': cachedAt.toUtc().toIso8601String(),
      'hasMore': hasMore,
      'nextOffset': nextOffset,
      'stops': stops.map(_stopToJson).toList(growable: false),
    };
  }

  static CachedStops? fromJson(Object? value) {
    final json = asJsonMap(value);
    if (json == null) {
      return null;
    }

    final schemaVersion = readInt(json, const [
      ['schemaVersion'],
    ]);
    if (schemaVersion == null || schemaVersion != stopsCacheSchemaVersion) {
      return null;
    }

    final cachedAt = readDateTime(json, const [
      ['cachedAt'],
    ]);
    final stopsValue = readJsonValue(json, const [
      ['stops'],
    ]);
    if (cachedAt == null || stopsValue is! List) {
      return null;
    }

    final stops = <Stop>[];
    for (final stopValue in stopsValue) {
      final stop = _stopFromJson(stopValue);
      if (stop == null) {
        return null;
      }

      stops.add(stop);
    }

    return CachedStops(
      schemaVersion: stopsCacheSchemaVersion,
      cachedAt: cachedAt,
      stops: List<Stop>.unmodifiable(stops),
      hasMore:
          readBool(json, const [
            ['hasMore'],
          ]) ??
          false,
      nextOffset:
          readInt(json, const [
            ['nextOffset'],
          ]) ??
          stops.length,
    );
  }
}

bool isStopsCacheFresh(
  CachedStops? cache,
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

JsonMap _stopToJson(Stop stop) {
  return {
    'id': stop.id,
    'name': stop.name,
    if (stop.platformCode != null) 'platformCode': stop.platformCode,
    if (stop.zoneId != null) 'zoneId': stop.zoneId,
    if (stop.locationType != null) 'locationType': stop.locationType,
    if (stop.parentStationId != null) 'parentStationId': stop.parentStationId,
    if (stop.wheelchairBoarding != null)
      'wheelchairBoarding': stop.wheelchairBoarding,
    if (stop.levelId != null) 'levelId': stop.levelId,
    if (stop.latitude != null) 'latitude': stop.latitude,
    if (stop.longitude != null) 'longitude': stop.longitude,
  };
}

Stop? _stopFromJson(Object? value) {
  final json = asJsonMap(value);
  if (json == null) {
    return null;
  }

  final id = readString(json, const [
    ['id'],
  ]);
  final name = readString(json, const [
    ['name'],
  ]);
  if (id == null || name == null) {
    return null;
  }

  return Stop(
    id: id,
    name: name,
    platformCode: readString(json, const [
      ['platformCode'],
    ]),
    zoneId: readString(json, const [
      ['zoneId'],
    ]),
    locationType: readInt(json, const [
      ['locationType'],
    ]),
    parentStationId: readString(json, const [
      ['parentStationId'],
    ]),
    wheelchairBoarding: readInt(json, const [
      ['wheelchairBoarding'],
    ]),
    levelId: readString(json, const [
      ['levelId'],
    ]),
    latitude: readDouble(json, const [
      ['latitude'],
    ]),
    longitude: readDouble(json, const [
      ['longitude'],
    ]),
  );
}
