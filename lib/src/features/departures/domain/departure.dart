import '../../../core/domain/pid_line_classifier.dart';
import '../../../core/domain/pid_line_type.dart';

class Departure {
  const Departure({
    required this.routeShortName,
    required this.headsign,
    required this.departureTime,
    this.routeType,
    this.delaySeconds,
    this.platform,
    this.stopId,
    this.gtfsTripId,
    this.vehicleId,
  });

  final String routeShortName;
  final String headsign;
  final DateTime departureTime;
  final String? routeType;
  final int? delaySeconds;
  final String? platform;
  final String? stopId;
  final String? gtfsTripId;
  final String? vehicleId;

  PidLineType get lineType {
    final page = pidLinePageFromGolemioRouteType(routeType);
    if (page == null) {
      return guessFromShortName(routeShortName);
    }

    return fromPidPage(page: page, shortName: routeShortName);
  }
}
