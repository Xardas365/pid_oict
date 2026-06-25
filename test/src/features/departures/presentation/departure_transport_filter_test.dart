import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/domain/pid_line_type.dart';
import 'package:pid_oict/src/features/departures/domain/departure.dart';
import 'package:pid_oict/src/features/departures/presentation/departure_transport_filter.dart';

void main() {
  group('departure transport filters', () {
    test('derives available modes in stable display order', () {
      final departures = [
        _departure(routeShortName: '175', routeType: 'bus'),
        _departure(routeShortName: '10', routeType: 'tram'),
        _departure(routeShortName: 'A'),
        _departure(routeShortName: 'S7', routeType: 'train'),
      ];

      expect(deriveDepartureTransportModes(departures), [
        PidTransportMode.metro,
        PidTransportMode.tram,
        PidTransportMode.bus,
        PidTransportMode.train,
      ]);
    });

    test('filters departures by selected transport mode', () {
      final tram = _departure(routeShortName: '10', routeType: 'tram');
      final bus = _departure(routeShortName: '175', routeType: 'bus');

      expect(filterDeparturesByTransportMode([tram, bus], null), [tram, bus]);
      expect(
        filterDeparturesByTransportMode([tram, bus], PidTransportMode.bus),
        [bus],
      );
    });

    test('uses the first available mode as representative line type', () {
      final departures = [
        _departure(routeShortName: '175', routeType: 'bus'),
        _departure(routeShortName: 'S7', routeType: 'train'),
      ];

      expect(
        representativeLineTypeForDepartures(departures),
        PidLineType.cityBus,
      );
      expect(
        representativeLineTypeForDepartures(const []),
        PidLineType.unknown,
      );
    });
  });
}

Departure _departure({required String routeShortName, String? routeType}) {
  return Departure(
    routeShortName: routeShortName,
    routeType: routeType,
    headsign: 'Centrum',
    departureTime: DateTime(2026, 6, 22, 10, 15),
  );
}
