import '../domain/stop.dart';
import '../domain/stop_group.dart';
import '../domain/stop_visibility.dart';

List<Stop> filterStopsByName(List<Stop> stops, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  final displayableStops = stops.where(isDisplayablePassengerStop);

  if (normalizedQuery.isEmpty) {
    return List<Stop>.unmodifiable(displayableStops);
  }

  return displayableStops
      .where((stop) => stop.name.toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
}

List<StopGroup> filterStopGroupsByName(List<StopGroup> groups, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  final displayableGroups = groups.where(isDisplayablePassengerStopGroup);

  if (normalizedQuery.isEmpty) {
    return List<StopGroup>.unmodifiable(displayableGroups);
  }

  return displayableGroups
      .where((group) => group.name.toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
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

/// Conservative UI cleanup for GTFS records that are infrastructure markers
/// rather than passenger-facing stops. The data repository applies the strict
/// public-stop predicate; this remains a light defensive guard for injected
/// tests or future non-Golemio sources.
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
