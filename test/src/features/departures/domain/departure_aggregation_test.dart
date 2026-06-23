import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/domain/departure_aggregation.dart';

void main() {
  group('departure aggregation', () {
    test('deduplicates departures by gtfsTripId', () {
      final departures = deduplicateDepartures([
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 12,
          gtfsTripId: 'trip-10-repy',
          platform: 'A',
        ),
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 12,
          gtfsTripId: 'trip-10-repy',
          platform: 'B',
        ),
      ]);

      expect(departures, hasLength(1));
      expect(departures.single.gtfsTripId, 'trip-10-repy');
      expect(departures.single.platform, 'A');
    });

    test('keeps richer context when duplicate trip times match', () {
      final departures = deduplicateDepartures([
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 12,
          gtfsTripId: 'trip-10-repy',
        ),
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 12,
          gtfsTripId: 'trip-10-repy',
          platform: 'B',
          stopId: 'U118Z102P',
        ),
      ]);

      expect(departures.single.platform, 'B');
      expect(departures.single.stopId, 'U118Z102P');
    });

    test('deduplicates by fallback key when gtfsTripId is missing', () {
      final departures = deduplicateDepartures([
        _departure(
          route: 'A',
          headsign: 'Nemocnice Motol',
          minutes: 8,
          platform: '1',
          stopId: 'U1Z1',
        ),
        _departure(
          route: 'A',
          headsign: 'Nemocnice Motol',
          minutes: 8,
          platform: '1',
          stopId: 'U1Z1',
        ),
        _departure(
          route: 'A',
          headsign: 'Nemocnice Motol',
          minutes: 8,
          platform: '2',
          stopId: 'U1Z2',
        ),
      ]);

      expect(departures, hasLength(2));
      expect(departures.map((departure) => departure.platform), ['1', '2']);
    });

    test('sorts departures by nearest departure time deterministically', () {
      final departures = sortDeparturesByTime([
        _departure(route: '22', headsign: 'B', minutes: 20),
        _departure(route: '10', headsign: 'C', minutes: 5),
        _departure(route: '9', headsign: 'A', minutes: 5),
      ]);

      expect(departures.map((departure) => departure.routeShortName), [
        '10',
        '9',
        '22',
      ]);
    });

    test('aggregates by deduplicating and sorting', () {
      final departures = aggregateDepartures([
        _departure(
          route: '22',
          headsign: 'Nadrazi Hostivar',
          minutes: 12,
          gtfsTripId: 'trip-22',
        ),
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 5,
          gtfsTripId: 'trip-10',
        ),
        _departure(
          route: '10',
          headsign: 'Sidliste Repy',
          minutes: 5,
          gtfsTripId: 'trip-10',
        ),
      ]);

      expect(departures, hasLength(2));
      expect(departures.map((departure) => departure.gtfsTripId), [
        'trip-10',
        'trip-22',
      ]);
    });
  });
}

Departure _departure({
  required String route,
  required String headsign,
  required int minutes,
  String? platform,
  String? stopId,
  String? gtfsTripId,
}) {
  return Departure(
    routeShortName: route,
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, minutes),
    platform: platform,
    stopId: stopId,
    gtfsTripId: gtfsTripId,
  );
}
