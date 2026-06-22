import '../domain/stop.dart';

List<Stop> filterStopsByName(List<Stop> stops, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<Stop>.unmodifiable(stops);
  }

  return stops
      .where((stop) => stop.name.toLowerCase().contains(normalizedQuery))
      .toList(growable: false);
}
