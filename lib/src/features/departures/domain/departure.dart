import 'package:meta/meta.dart';

import '../../../core/domain/pid_line_classifier.dart';
import '../../../core/domain/pid_line_type.dart';

@immutable
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
    this.isWheelchairAccessible,
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
  final bool? isWheelchairAccessible;

  PidLineType get lineType {
    final page = pidLinePageFromGolemioRouteType(routeType);
    if (page == null) {
      return guessFromShortName(routeShortName);
    }

    return fromPidPage(page: page, shortName: routeShortName);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Departure &&
            routeShortName == other.routeShortName &&
            headsign == other.headsign &&
            departureTime == other.departureTime &&
            routeType == other.routeType &&
            delaySeconds == other.delaySeconds &&
            platform == other.platform &&
            stopId == other.stopId &&
            gtfsTripId == other.gtfsTripId &&
            vehicleId == other.vehicleId &&
            isWheelchairAccessible == other.isWheelchairAccessible;
  }

  @override
  int get hashCode {
    return Object.hash(
      routeShortName,
      headsign,
      departureTime,
      routeType,
      delaySeconds,
      platform,
      stopId,
      gtfsTripId,
      vehicleId,
      isWheelchairAccessible,
    );
  }
}
