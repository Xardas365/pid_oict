import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/presentation/stop_filter.dart';

void main() {
  group('filterStopsByName', () {
    const stops = [
      Stop(id: '1', name: 'Staromestska'),
      Stop(id: '2', name: 'Andel'),
      Stop(id: '3', name: 'Hlavni nadrazi'),
    ];

    test('returns all stops for a blank query', () {
      expect(filterStopsByName(stops, '   '), stops);
    });

    test('filters stops locally by case-insensitive name match', () {
      final result = filterStopsByName(stops, 'AND');

      expect(result, hasLength(1));
      expect(result.single.name, 'Andel');
    });

    test('returns an empty list when no stop matches', () {
      expect(filterStopsByName(stops, 'airport'), isEmpty);
    });

    test('hides conservative technical infrastructure records', () {
      const mixedStops = [
        Stop(id: '1', name: 'Staromestska'),
        Stop(id: '2', name: 'hr.VUSC Praha'),
        Stop(id: '3', name: 'Km 12,4'),
        Stop(id: '4', name: 'km 8,1'),
        Stop(id: '5', name: 'Odb Balabenka'),
        Stop(id: '6', name: 'Kmetineves'),
        Stop(id: '7', name: 'Odboraru'),
        Stop(id: '8', name: 'vl. v km 12,4'),
        Stop(id: '9', name: 'Kolín výh.č.1'),
        Stop(id: '10', name: 'vjezd.náv Praha'),
        Stop(id: '11', name: 'odj.náv Praha'),
        Stop(id: '12', name: 'Praha náv. 1'),
      ];

      final result = filterStopsByName(mixedStops, '');

      expect(result.map((stop) => stop.name), [
        'Staromestska',
        'Kmetineves',
        'Odboraru',
      ]);
    });

    test('hides non-passenger GTFS location types when available', () {
      const mixedStops = [
        Stop(id: '1', name: 'Flora', locationType: 0),
        Stop(id: '2', name: 'Flora station', locationType: 1),
        Stop(id: '3', name: 'Flora entrance', locationType: 2),
        Stop(id: '4', name: 'Andel'),
      ];

      final result = filterStopsByName(mixedStops, '');

      expect(result.map((stop) => stop.name), ['Flora', 'Andel']);
    });

    test('does not reveal technical records during search', () {
      const mixedStops = [
        Stop(id: '1', name: 'Km 12,4'),
        Stop(id: '2', name: 'Kmetineves'),
      ];

      final result = filterStopsByName(mixedStops, 'km');

      expect(result, hasLength(1));
      expect(result.single.name, 'Kmetineves');
    });
  });
}
