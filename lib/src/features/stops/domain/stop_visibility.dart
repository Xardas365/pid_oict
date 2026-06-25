import 'stop.dart';
import 'stop_group.dart';

/// Public GTFS stops that can be selected for PID departure boards.
///
/// The raw `/v2/gtfs/stops` feed also contains infrastructure and railway
/// marker records. Those IDs can look valid enough to parse, but they are not
/// useful in the passenger-facing stop list and often fail against public
/// departure boards. Keep this predicate strict and isolated so it can be
/// refined if Golemio exposes a stronger public-stop discriminator later.
bool isUserFacingStop(Stop stop) {
  final id = stop.id.trim();
  final name = stop.name.trim();

  if (id.isEmpty || name.isEmpty) {
    return false;
  }

  if (!id.startsWith('U')) {
    return false;
  }

  if (stop.locationType != 0) {
    return false;
  }

  final zoneId = stop.zoneId?.trim();
  if (zoneId == null || zoneId.isEmpty) {
    return false;
  }

  if (!_hasUsableCoordinates(stop)) {
    return false;
  }

  return !isTechnicalStopName(name);
}

bool isTechnicalStopName(String name) {
  final normalized = name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  if (normalized.isEmpty) {
    return true;
  }

  return normalized.startsWith('hr.') ||
      RegExp(r'^km\b').hasMatch(normalized) ||
      RegExp(r'^odb\b').hasMatch(normalized) ||
      normalized.contains('vl. v km') ||
      normalized.contains('výh.') ||
      normalized.contains('vyh.') ||
      normalized.contains('vjezd.náv') ||
      normalized.contains('vjezd.nav') ||
      normalized.contains('odj.náv') ||
      normalized.contains('odj.nav') ||
      normalized.contains('náv.') ||
      normalized.contains('nav.');
}

/// Defensive guard for grouped stop sources. Production Golemio data is already
/// filtered in the repository, but injected tests and future sources should not
/// surface obvious infrastructure groups in the public stops list.
bool isDisplayablePassengerStopGroup(StopGroup group) {
  final normalizedName = group.name.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalizedName.isEmpty || isTechnicalStopName(normalizedName)) {
    return false;
  }

  return group.stops.any(isDisplayablePassengerStop);
}

/// Conservative cleanup for GTFS records that are infrastructure markers rather
/// than passenger-facing stops. The data repository applies the stricter public
/// stop predicate; this remains a light defensive guard for injected tests,
/// restored cache data, or future non-Golemio sources.
bool isDisplayablePassengerStop(Stop stop) {
  final locationType = stop.locationType;
  if (locationType != null && locationType != 0) {
    return false;
  }

  final normalizedName = stop.name.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalizedName.isEmpty) {
    return false;
  }

  return !isTechnicalStopName(normalizedName);
}

List<Stop> sortedUserFacingStops(Iterable<Stop> stops) {
  final sortedStops = stops.where(isUserFacingStop).toList(growable: false)
    ..sort(_compareStopsByPublicName);

  return List<Stop>.unmodifiable(sortedStops);
}

bool _hasUsableCoordinates(Stop stop) {
  final latitude = stop.latitude;
  final longitude = stop.longitude;

  if (latitude == null || longitude == null) {
    return false;
  }

  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

int _compareStopsByPublicName(Stop first, Stop second) {
  final nameComparison = first.name.toLowerCase().compareTo(
    second.name.toLowerCase(),
  );
  if (nameComparison != 0) {
    return nameComparison;
  }

  final platformComparison = (first.platformCode ?? '').compareTo(
    second.platformCode ?? '',
  );
  if (platformComparison != 0) {
    return platformComparison;
  }

  return first.id.compareTo(second.id);
}
