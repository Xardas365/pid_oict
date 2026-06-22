import '../../../../shared/utils/json_parsing.dart';
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
    final id = readString(json, [
      ['stop_id'],
      ['id'],
      ['gtfs_id'],
      ['properties', 'stop_id'],
      ['properties', 'id'],
      ['properties', 'gtfs_id'],
    ]);
    final name = readString(json, [
      ['stop_name'],
      ['name'],
      ['properties', 'stop_name'],
      ['properties', 'name'],
    ]);

    if (id == null || name == null) {
      return null;
    }

    final coordinates = readGeoJsonPoint(json);

    return StopDto(
      id: id,
      name: name,
      platformCode: readString(json, [
        ['platform_code'],
        ['platform'],
        ['code'],
        ['properties', 'platform_code'],
        ['properties', 'platform'],
        ['properties', 'code'],
      ]),
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
    );
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
