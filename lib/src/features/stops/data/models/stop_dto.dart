import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/stop.dart';

class StopDto {
  const StopDto({
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

  static StopDto? fromJson(JsonMap json) {
    final id = readString(json, _idPaths);
    final name = readString(json, _namePaths);

    if (id == null || name == null) {
      return null;
    }

    final coordinates = readGeoJsonPoint(json);

    return StopDto(
      id: id,
      name: name,
      platformCode: readString(json, _platformPaths),
      zoneId: readString(json, _zonePaths),
      locationType: readInt(json, _locationTypePaths),
      parentStationId: readString(json, _parentStationPaths),
      wheelchairBoarding: readInt(json, _wheelchairBoardingPaths),
      levelId: readString(json, _levelPaths),
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
    );
  }

  static ParsedResult<StopDto> parseWithDiagnostics(Object? response) {
    return parseJsonRecordsWithDiagnostics<StopDto>(
      response: response,
      parse: StopDto.fromJson,
      skipReason: invalidReason,
    );
  }

  static String invalidReason(JsonMap json) {
    if (readString(json, _idPaths) == null) {
      return 'missing required stop id';
    }

    if (readString(json, _namePaths) == null) {
      return 'missing display name';
    }

    return 'invalid stop record';
  }

  Stop toDomain() {
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
    );
  }
}

const _idPaths = [
  ['stop_id'],
  ['id'],
  ['gtfs_id'],
  ['properties', 'stop_id'],
  ['properties', 'id'],
  ['properties', 'gtfs_id'],
];

const _namePaths = [
  ['stop_name'],
  ['name'],
  ['properties', 'stop_name'],
  ['properties', 'name'],
];

const _platformPaths = [
  ['platform_code'],
  ['platform'],
  ['code'],
  ['properties', 'platform_code'],
  ['properties', 'platform'],
  ['properties', 'code'],
];

const _zonePaths = [
  ['zone_id'],
  ['zoneId'],
  ['zone'],
  ['properties', 'zone_id'],
  ['properties', 'zoneId'],
  ['properties', 'zone'],
];

const _locationTypePaths = [
  ['location_type'],
  ['locationType'],
  ['properties', 'location_type'],
  ['properties', 'locationType'],
];

const _parentStationPaths = [
  ['parent_station'],
  ['parentStation'],
  ['properties', 'parent_station'],
  ['properties', 'parentStation'],
];

const _wheelchairBoardingPaths = [
  ['wheelchair_boarding'],
  ['wheelchairBoarding'],
  ['properties', 'wheelchair_boarding'],
  ['properties', 'wheelchairBoarding'],
];

const _levelPaths = [
  ['level_id'],
  ['levelId'],
  ['properties', 'level_id'],
  ['properties', 'levelId'],
];
