import '../domain/stop.dart';

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

/// Conservative UI cleanup for GTFS records that are infrastructure markers
/// rather than passenger-facing stops. The current DTO does not expose a more
/// reliable stop type field, so keep this limited to well-known technical
/// prefixes and never to a curated allow-list of demo stops.
bool isDisplayablePassengerStop(Stop stop) {
  final normalizedName = stop.name.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalizedName.isEmpty) {
    return false;
  }

  return !_technicalStopPrefix.hasMatch(normalizedName);
}

final _technicalStopPrefix = RegExp(
  r'^(hr\.|km\b|odb\b)',
  caseSensitive: false,
);
