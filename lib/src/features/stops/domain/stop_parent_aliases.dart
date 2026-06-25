import 'stop.dart';
import 'stop_visibility.dart';

Map<String, String> parentStationNamesById(Iterable<Stop> stops) {
  final parentNamesById = <String, String>{};

  for (final stop in stops) {
    final id = stop.id.trim();
    final name = stop.name.trim();
    if (id.isEmpty ||
        name.isEmpty ||
        stop.locationType == 0 ||
        isTechnicalStopName(name)) {
      continue;
    }

    parentNamesById.putIfAbsent(id, () => name);
  }

  final sortedEntries = parentNamesById.entries.toList(growable: false)
    ..sort((first, second) => first.key.compareTo(second.key));

  return Map<String, String>.unmodifiable({
    for (final entry in sortedEntries) entry.key: entry.value,
  });
}

List<Stop> attachParentStationAliases(
  Iterable<Stop> stops,
  Map<String, String> parentStationNamesById,
) {
  final aliasedStops = stops
      .map((stop) {
        final parentStationId = stop.parentStationId?.trim();
        final parentName = parentStationId == null
            ? null
            : parentStationNamesById[parentStationId];
        if (parentName == null || parentName.trim().isEmpty) {
          return stop;
        }

        return stop.withSearchAliases([...stop.searchAliases, parentName]);
      })
      .toList(growable: false);

  return List<Stop>.unmodifiable(aliasedStops);
}
