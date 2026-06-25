import 'departure.dart';

List<Departure> aggregateDepartures(List<Departure> departures) {
  return sortDeparturesByTime(deduplicateDepartures(departures));
}

List<Departure> deduplicateDepartures(List<Departure> departures) {
  final departuresByKey = <String, Departure>{};

  for (final departure in departures) {
    final key = departureDeduplicationKey(departure);
    final existing = departuresByKey[key];
    departuresByKey[key] = existing == null
        ? departure
        : _preferredDeparture(existing, departure);
  }

  return List<Departure>.unmodifiable(departuresByKey.values);
}

List<Departure> sortDeparturesByTime(List<Departure> departures) {
  final sortedDepartures = departures.toList(growable: false)
    ..sort(_compareDepartures);

  return List<Departure>.unmodifiable(sortedDepartures);
}

String departureDeduplicationKey(Departure departure) {
  final gtfsTripId = departure.gtfsTripId?.trim();
  if (gtfsTripId != null && gtfsTripId.isNotEmpty) {
    return 'trip:$gtfsTripId';
  }

  return [
    'fallback',
    _normalizeKeyPart(departure.routeShortName),
    _normalizeKeyPart(departure.headsign),
    departure.departureTime.toUtc().toIso8601String(),
    _normalizeKeyPart(departure.stopId),
    _normalizeKeyPart(departure.platform),
  ].join('|');
}

Departure _preferredDeparture(Departure existing, Departure candidate) {
  final timeComparison = candidate.departureTime.compareTo(
    existing.departureTime,
  );
  if (timeComparison < 0) {
    return candidate;
  }

  if (timeComparison > 0) {
    return existing;
  }

  final existingContextScore = _contextScore(existing);
  final candidateContextScore = _contextScore(candidate);
  if (candidateContextScore > existingContextScore) {
    return candidate;
  }

  return existing;
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

  final platformComparison = (first.platform ?? '').toLowerCase().compareTo(
    (second.platform ?? '').toLowerCase(),
  );
  if (platformComparison != 0) {
    return platformComparison;
  }

  return (first.stopId ?? '').toLowerCase().compareTo(
    (second.stopId ?? '').toLowerCase(),
  );
}

int _contextScore(Departure departure) {
  var score = 0;
  if (departure.platform?.trim().isNotEmpty ?? false) {
    score++;
  }
  if (departure.stopId?.trim().isNotEmpty ?? false) {
    score++;
  }
  if (departure.vehicleId?.trim().isNotEmpty ?? false) {
    score++;
  }
  if (departure.isWheelchairAccessible != null) {
    score++;
  }
  return score;
}

String _normalizeKeyPart(String? value) {
  return value?.trim().toLowerCase() ?? '';
}
