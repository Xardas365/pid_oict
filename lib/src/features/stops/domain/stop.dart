import 'package:meta/meta.dart';

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
            longitude == other.longitude;
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
    );
  }
}
