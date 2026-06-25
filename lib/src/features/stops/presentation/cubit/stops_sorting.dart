import '../../domain/stop.dart';

List<Stop> sortStopsByPublicName(Iterable<Stop> stops) {
  final sortedStops = stops.toList(growable: false)
    ..sort(compareStopsByPublicName);

  return List<Stop>.unmodifiable(sortedStops);
}

int compareStopsByPublicName(Stop first, Stop second) {
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
