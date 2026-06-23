import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/data/models/departure_dto.dart';

void main() {
  group('DepartureDto', () {
    test('parses basic departure fields from nested JSON', () {
      final dto = DepartureDto.fromJson({
        'route': {'short_name': '22'},
        'trip': {'headsign': 'Nadrazi Hostivar', 'id': 'trip-22-123'},
        'departure': {
          'timestamp_scheduled': '2026-06-22T10:14:00+02:00',
          'predicted': '2026-06-22T10:15:30+02:00',
          'delay_seconds': '120',
        },
        'stop': {'id': 'U123Z1', 'platform_code': '3'},
      });

      expect(dto, isNotNull);
      expect(dto!.routeShortName, '22');
      expect(dto.headsign, 'Nadrazi Hostivar');
      expect(dto.departureTime, DateTime.parse('2026-06-22T10:15:30+02:00'));
      expect(dto.delaySeconds, 120);
      expect(dto.platform, '3');
      expect(dto.stopId, 'U123Z1');
      expect(dto.gtfsTripId, 'trip-22-123');

      final departure = dto.toDomain();

      expect(departure.routeShortName, dto.routeShortName);
      expect(departure.headsign, dto.headsign);
      expect(departure.departureTime, dto.departureTime);
    });

    test('prefers predicted departure time over scheduled time', () {
      final dto = DepartureDto.fromJson({
        'route': {'short_name': '22'},
        'trip': {'headsign': 'Nadrazi Hostivar'},
        'departure': {
          'timestamp_scheduled': '2026-06-22T10:15:00+02:00',
          'timestamp_predicted': '2026-06-22T10:17:00+02:00',
        },
      });

      expect(dto, isNotNull);
      expect(dto!.departureTime, DateTime.parse('2026-06-22T10:17:00+02:00'));
    });

    test('tolerates missing optional fields', () {
      final dto = DepartureDto.fromJson({
        'line': 'A',
        'destination': 'Nemocnice Motol',
        'departure_time': '2026-06-22T10:15:30Z',
      });

      expect(dto, isNotNull);
      expect(dto!.delaySeconds, isNull);
      expect(dto.platform, isNull);
      expect(dto.gtfsTripId, isNull);
    });

    test('parses numeric epoch departure timestamps', () {
      final dto = DepartureDto.fromJson({
        'line': 'A',
        'destination': 'Nemocnice Motol',
        'departure_time': 1782123330,
      });

      expect(dto, isNotNull);
      expect(
        dto!.departureTime,
        DateTime.fromMillisecondsSinceEpoch(1782123330000, isUtc: true),
      );
    });

    test('parses gtfsTripId from tolerant API paths', () {
      for (final record in [
        {
          'line': '22',
          'destination': 'Nadrazi Hostivar',
          'departure_time': '2026-06-22T10:15:30Z',
          'departure': {
            'trip': {'id': 'trip-from-departure'},
          },
        },
        {
          'line': '22',
          'destination': 'Nadrazi Hostivar',
          'departure_time': '2026-06-22T10:15:30Z',
          'trip': {'gtfs_trip_id': 'trip-from-trip'},
        },
        {
          'line': '22',
          'destination': 'Nadrazi Hostivar',
          'departure_time': '2026-06-22T10:15:30Z',
          'gtfs_trip_id': 'trip-from-root',
        },
        {
          'properties': {
            'line': '22',
            'destination': 'Nadrazi Hostivar',
            'departure_time': '2026-06-22T10:15:30Z',
            'departure': {
              'trip': {'id': 'trip-from-properties-departure'},
            },
          },
        },
        {
          'properties': {
            'line': '22',
            'destination': 'Nadrazi Hostivar',
            'departure_time': '2026-06-22T10:15:30Z',
            'trip': {'id': 'trip-from-properties-trip'},
          },
        },
        {
          'properties': {
            'line': '22',
            'destination': 'Nadrazi Hostivar',
            'departure_time': '2026-06-22T10:15:30Z',
            'gtfs_trip_id': 'trip-from-properties-root',
          },
        },
      ]) {
        final dto = DepartureDto.fromJson(record);

        expect(dto?.gtfsTripId, startsWith('trip-from-'));
      }
    });

    test('parses public departure board groups from nested list response', () {
      final result = DepartureDto.parseWithDiagnostics([
        [
          {
            'route': {'short_name': '10'},
            'trip': {'headsign': 'Sidliste Repy', 'id': 'trip-10-repy'},
            'departure': {
              'timestamp_predicted': '2026-06-22T10:15:30+02:00',
              'delay_seconds': 60,
            },
            'stop': {'platform_code': '3'},
          },
        ],
      ]);

      expect(result.diagnostics.rawCount, 1);
      expect(result.diagnostics.parsedCount, 1);
      expect(result.diagnostics.skippedCount, 0);
      expect(result.items.single.routeShortName, '10');
      expect(result.items.single.headsign, 'Sidliste Repy');
      expect(result.items.single.platform, '3');
      expect(result.items.single.gtfsTripId, 'trip-10-repy');
    });

    test('rejects records with invalid required data', () {
      expect(
        DepartureDto.fromJson({
          'line': 'A',
          'destination': 'Nemocnice Motol',
          'departure_time': 'not a date',
        }),
        isNull,
      );
      expect(
        DepartureDto.fromJson({
          'destination': 'Nemocnice Motol',
          'departure_time': '2026-06-22T10:15:30Z',
        }),
        isNull,
      );
      expect(
        DepartureDto.fromJson({'line': 'A', 'destination': 'Nemocnice Motol'}),
        isNull,
      );
    });
  });
}
