import '../../../core/domain/pid_line_type.dart';
import '../domain/departure.dart';

class DeparturePlatformSection {
  const DeparturePlatformSection({
    required this.platformCode,
    required this.label,
    required this.departures,
    required this.earliestDepartureTime,
    required this.transportModes,
  });

  final String? platformCode;
  final String label;
  final List<Departure> departures;
  final DateTime earliestDepartureTime;
  final List<PidTransportMode> transportModes;
}

List<DeparturePlatformSection> groupDeparturesByPlatform(
  List<Departure> departures, {
  required String Function(String platformCode) platformLabelBuilder,
  required String unknownPlatformLabel,
}) {
  final departuresByPlatform = <String, List<Departure>>{};
  for (final departure in departures) {
    final platformCode = _normalizedPlatformCode(departure.platform);
    departuresByPlatform
        .putIfAbsent(platformCode ?? '', () => <Departure>[])
        .add(departure);
  }

  final sections =
      departuresByPlatform.entries
          .map((entry) {
            final sortedDepartures = entry.value.toList(growable: false)
              ..sort(_compareDepartures);
            final platformCode = entry.key.isEmpty ? null : entry.key;

            return DeparturePlatformSection(
              platformCode: platformCode,
              label: platformCode == null
                  ? unknownPlatformLabel
                  : platformLabelBuilder(platformCode),
              departures: List<Departure>.unmodifiable(sortedDepartures),
              earliestDepartureTime: sortedDepartures.first.departureTime,
              transportModes: _transportModes(sortedDepartures),
            );
          })
          .toList(growable: false)
        ..sort(_compareSections);

  return List<DeparturePlatformSection>.unmodifiable(sections);
}

String? _normalizedPlatformCode(String? platform) {
  final normalizedPlatform = platform?.trim();
  if (normalizedPlatform == null || normalizedPlatform.isEmpty) {
    return null;
  }

  return normalizedPlatform;
}

List<PidTransportMode> _transportModes(List<Departure> departures) {
  final modes = <PidTransportMode>{};
  for (final departure in departures) {
    modes.add(departure.lineType.mode);
  }

  final sortedModes = modes.toList(growable: false)
    ..sort((first, second) => first.index.compareTo(second.index));
  return List<PidTransportMode>.unmodifiable(sortedModes);
}

int _compareSections(
  DeparturePlatformSection first,
  DeparturePlatformSection second,
) {
  final timeComparison = first.earliestDepartureTime.compareTo(
    second.earliestDepartureTime,
  );
  if (timeComparison != 0) {
    return timeComparison;
  }

  return first.label.toLowerCase().compareTo(second.label.toLowerCase());
}

int _compareDepartures(Departure first, Departure second) {
  final timeComparison = first.departureTime.compareTo(second.departureTime);
  if (timeComparison != 0) {
    return timeComparison;
  }

  final routeComparison = first.routeShortName.toLowerCase().compareTo(
    second.routeShortName.toLowerCase(),
  );
  if (routeComparison != 0) {
    return routeComparison;
  }

  final headsignComparison = first.headsign.toLowerCase().compareTo(
    second.headsign.toLowerCase(),
  );
  if (headsignComparison != 0) {
    return headsignComparison;
  }

  return (first.stopId ?? '').toLowerCase().compareTo(
    (second.stopId ?? '').toLowerCase(),
  );
}
