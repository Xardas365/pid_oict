class Departure {
  const Departure({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.delaySeconds,
    this.platform,
    this.gtfsTripId,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final int? delaySeconds;
  final String? platform;
  final String? gtfsTripId;
}
