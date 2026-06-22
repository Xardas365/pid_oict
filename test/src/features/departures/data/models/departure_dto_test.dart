import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/data/models/departure_dto.dart';

void main() {
  group('DepartureDto', () {
    test('parses basic departure fields from nested JSON', () {
      final dto = DepartureDto.fromJson({
        'route': {'short_name': '22'},
        'trip': {'headsign': 'Nadrazi Hostivar'},
        'departure': {
          'predicted': '2026-06-22T10:15:30+02:00',
          'delay_seconds': '120',
        },
        'platform': '3',
        'vehicle': {'id': 'vehicle-123'},
      });

      expect(dto, isNotNull);
      expect(dto!.routeShortName, '22');
      expect(dto.headsign, 'Nadrazi Hostivar');
      expect(dto.departureTime, DateTime.parse('2026-06-22T10:15:30+02:00'));
      expect(dto.delaySeconds, 120);
      expect(dto.platform, '3');
      expect(dto.vehicleId, 'vehicle-123');

      final departure = dto.toDomain();

      expect(departure.routeShortName, dto.routeShortName);
      expect(departure.headsign, dto.headsign);
      expect(departure.departureTime, dto.departureTime);
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
      expect(dto.vehicleId, isNull);
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
