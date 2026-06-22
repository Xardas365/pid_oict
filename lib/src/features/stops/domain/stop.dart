class Stop {
  const Stop({
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
}
