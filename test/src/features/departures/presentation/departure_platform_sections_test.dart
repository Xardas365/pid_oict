import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/presentation/departure_platform_sections.dart';

void main() {
  group('groupDeparturesByPlatform', () {
    test('groups departures by platform code', () {
      final sections = _sections([
        _departure('Skalka', platform: 'D'),
        _departure('Cukrovar Cakovice', routeShortName: '911', platform: 'D'),
        _departure(
          'Sidliste Repy',
          routeShortName: '10',
          platform: 'B',
          minutes: 10,
        ),
      ]);

      expect(sections, hasLength(2));
      expect(sections.first.platformCode, 'D');
      expect(sections.first.label, 'Platform D');
      expect(
        sections.first.departures.map((departure) => departure.headsign),
        ['Skalka', 'Cukrovar Cakovice'],
      );
      expect(sections.last.platformCode, 'B');
    });

    test('uses fallback label for missing platform code', () {
      final sections = _sections([
        _departure('Skalka', platform: ' '),
      ]);

      expect(sections.single.platformCode, isNull);
      expect(sections.single.label, 'Unknown platform');
    });

    test('sorts sections by earliest departure time', () {
      final sections = _sections([
        _departure('Later A', platform: 'A', minutes: 20),
        _departure('Soon B', platform: 'B', minutes: 4),
        _departure('Middle A', platform: 'A', minutes: 12),
      ]);

      expect(sections.map((section) => section.platformCode), ['B', 'A']);
      expect(sections.first.earliestDepartureTime.minute, 4);
    });

    test('sorts departures inside a section by time', () {
      final sections = _sections([
        _departure('Later', routeShortName: '911', platform: 'D', minutes: 42),
        _departure('Soon', platform: 'D', minutes: 27),
      ]);

      expect(
        sections.single.departures.map((departure) => departure.headsign),
        [
          'Soon',
          'Later',
        ],
      );
    });

    test('reflects only visible departures after filtering', () {
      final sections = _sections([
        _departure(
          'Bus',
          routeShortName: '176',
          routeType: 'bus',
          platform: 'B',
        ),
      ]);

      expect(sections, hasLength(1));
      expect(sections.single.platformCode, 'B');
      expect(sections.single.transportModes, [PidTransportMode.bus]);
    });
  });
}

List<DeparturePlatformSection> _sections(List<Departure> departures) {
  return groupDeparturesByPlatform(
    departures,
    platformLabelBuilder: (platform) => 'Platform $platform',
    unknownPlatformLabel: 'Unknown platform',
  );
}

Departure _departure(
  String headsign, {
  String routeShortName = '905',
  String? routeType,
  String? platform,
  int minutes = 0,
}) {
  return Departure(
    routeShortName: routeShortName,
    routeType: routeType,
    headsign: headsign,
    departureTime: DateTime(2026, 6, 22, 10, minutes),
    platform: platform,
  );
}
