class Departure {
  const Departure({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.delaySeconds,
    this.platform,
    this.vehicleId,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final int? delaySeconds;
  final String? platform;
  final String? vehicleId;
}
