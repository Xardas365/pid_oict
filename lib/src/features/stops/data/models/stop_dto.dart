import '../../../../shared/utils/json_parsing.dart';
import '../../../../shared/utils/parser_diagnostics.dart';
import '../../domain/stop.dart';

class StopDto {
  const StopDto({
    required this.id,
    required this.name,
    this.platformCode,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String? platformCode;
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
