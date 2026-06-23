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
}
