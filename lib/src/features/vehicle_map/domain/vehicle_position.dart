import 'package:meta/meta.dart';

@immutable
class VehiclePosition {
  const VehiclePosition({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.gtfsTripId,
    this.routeShortName,
    this.routeType,
    this.headsign,
    this.bearing,
    this.delaySeconds,
    this.statePosition,
    this.lastStopSequence,
    this.shapeDistTraveled,
    this.routePoints = const <VehicleRoutePoint>[],
    this.stopTimes = const <VehicleRouteStop>[],
    this.vehicleDescriptor,
    this.lastUpdated,
  });

  final String vehicleId;
  final double latitude;
  final double longitude;
  final String? gtfsTripId;
  final String? routeShortName;
  final String? routeType;
  final String? headsign;
  final double? bearing;
  final int? delaySeconds;
  final String? statePosition;
  final int? lastStopSequence;
  final double? shapeDistTraveled;
  final List<VehicleRoutePoint> routePoints;
  final List<VehicleRouteStop> stopTimes;
  final VehicleDescriptor? vehicleDescriptor;
  final DateTime? lastUpdated;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehiclePosition &&
            vehicleId == other.vehicleId &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            gtfsTripId == other.gtfsTripId &&
            routeShortName == other.routeShortName &&
            routeType == other.routeType &&
            headsign == other.headsign &&
            bearing == other.bearing &&
            delaySeconds == other.delaySeconds &&
            statePosition == other.statePosition &&
            lastStopSequence == other.lastStopSequence &&
            shapeDistTraveled == other.shapeDistTraveled &&
            _listEquals(routePoints, other.routePoints) &&
            _listEquals(stopTimes, other.stopTimes) &&
            vehicleDescriptor == other.vehicleDescriptor &&
            lastUpdated == other.lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehicleId,
      latitude,
      longitude,
      gtfsTripId,
      routeShortName,
      routeType,
      headsign,
      bearing,
      delaySeconds,
      statePosition,
      lastStopSequence,
      shapeDistTraveled,
      Object.hashAll(routePoints),
      Object.hashAll(stopTimes),
      vehicleDescriptor,
      lastUpdated,
    );
  }
}

@immutable
class VehicleRoutePoint {
  const VehicleRoutePoint({
    required this.latitude,
    required this.longitude,
    this.shapeDistTraveled,
  });

  final double latitude;
  final double longitude;
  final double? shapeDistTraveled;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleRoutePoint &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            shapeDistTraveled == other.shapeDistTraveled;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, shapeDistTraveled);
}

@immutable
class VehicleRouteStop {
  const VehicleRouteStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.stopSequence,
    this.zoneId,
    this.shapeDistTraveled,
    this.arrivalTime,
    this.departureTime,
    this.realtimeArrivalTime,
    this.realtimeDepartureTime,
    this.isWheelchairAccessible,
  });

  final String name;
  final double latitude;
  final double longitude;
  final int? stopSequence;
  final String? zoneId;
  final double? shapeDistTraveled;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final DateTime? realtimeArrivalTime;
  final DateTime? realtimeDepartureTime;
  final bool? isWheelchairAccessible;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleRouteStop &&
            name == other.name &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            stopSequence == other.stopSequence &&
            zoneId == other.zoneId &&
            shapeDistTraveled == other.shapeDistTraveled &&
            arrivalTime == other.arrivalTime &&
            departureTime == other.departureTime &&
            realtimeArrivalTime == other.realtimeArrivalTime &&
            realtimeDepartureTime == other.realtimeDepartureTime &&
            isWheelchairAccessible == other.isWheelchairAccessible;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      latitude,
      longitude,
      stopSequence,
      zoneId,
      shapeDistTraveled,
      arrivalTime,
      departureTime,
      realtimeArrivalTime,
      realtimeDepartureTime,
      isWheelchairAccessible,
    );
  }
}

@immutable
class VehicleDescriptor {
  const VehicleDescriptor({
    this.operator,
    this.vehicleType,
    this.isWheelchairAccessible,
    this.isAirConditioned,
    this.hasUsbChargers,
    this.registrationNumber,
  });

  final String? operator;
  final String? vehicleType;
  final bool? isWheelchairAccessible;
  final bool? isAirConditioned;
  final bool? hasUsbChargers;
  final String? registrationNumber;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VehicleDescriptor &&
            operator == other.operator &&
            vehicleType == other.vehicleType &&
            isWheelchairAccessible == other.isWheelchairAccessible &&
            isAirConditioned == other.isAirConditioned &&
            hasUsbChargers == other.hasUsbChargers &&
            registrationNumber == other.registrationNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      operator,
      vehicleType,
      isWheelchairAccessible,
      isAirConditioned,
      hasUsbChargers,
      registrationNumber,
    );
  }
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (identical(first, second)) {
    return true;
  }

  if (first.length != second.length) {
    return false;
  }

  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) {
      return false;
    }
  }

  return true;
}
