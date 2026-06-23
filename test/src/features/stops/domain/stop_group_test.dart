import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('StopGroup', () {
    test('groups stop points by parent station first', () {
      final groups = groupStops([
        _stop(
          id: 'U118Z102P',
          name: 'Flora',
          parentStationId: 'U118S1',
          platformCode: 'B',
          latitude: 50.0783,
          longitude: 14.4634,
        ),
        _stop(
          id: 'U118Z101P',
          name: 'Flora',
          parentStationId: 'U118S1',
          platformCode: 'A',
          latitude: 50.0782,
          longitude: 14.4633,
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.id, 'U118S1');
      expect(groups.single.parentStationId, 'U118S1');
      expect(groups.single.stopIds, ['U118Z101P', 'U118Z102P']);
      expect(groups.single.platformCodes, ['A', 'B']);
      expect(groups.single.latitude, 50.0782);
      expect(groups.single.longitude, 14.4633);
    });

    test('falls back to normalized stop name without parent station', () {
      final groups = groupStops([
        _stop(id: 'U1Z1', name: '  Flora ', platformCode: 'A'),
        _stop(id: 'U1Z2', name: 'flora', platformCode: 'B'),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.id, 'name:flora');
      expect(groups.single.name, 'Flora');
      expect(groups.single.stopIds, ['U1Z1', 'U1Z2']);
    });

    test('chooses deterministic display name', () {
      final mostCommonName = groupStops([
        _stop(id: 'U1Z1', name: 'Flora', parentStationId: 'U1S1'),
        _stop(id: 'U1Z2', name: 'Želivského', parentStationId: 'U1S1'),
        _stop(id: 'U1Z3', name: 'Želivského', parentStationId: 'U1S1'),
      ]).single;

      final tiedName = groupStops([
        _stop(id: 'U2Z1', name: 'Beta', parentStationId: 'U2S1'),
        _stop(id: 'U2Z2', name: 'Alfa', parentStationId: 'U2S1'),
      ]).single;

      expect(mostCommonName.name, 'Želivského');
      expect(tiedName.name, 'Alfa');
    });

    test('deduplicates platform codes and sorts them naturally', () {
      final group = groupStops([
        _stop(id: 'U1Z1', name: 'Anděl', platformCode: '10'),
        _stop(id: 'U1Z2', name: 'Anděl', platformCode: '2'),
        _stop(id: 'U1Z3', name: 'Anděl', platformCode: '10'),
        _stop(id: 'U1Z4', name: 'Anděl', platformCode: 'A'),
      ]).single;

      expect(group.platformCodes, ['2', '10', 'A']);
    });

    test(
      'selects representative zone by frequency and then alphabetically',
      () {
        final group = groupStops([
          _stop(id: 'U1Z1', name: 'Anděl', zoneId: 'B'),
          _stop(id: 'U1Z2', name: 'Anděl', zoneId: 'P'),
          _stop(id: 'U1Z3', name: 'Anděl', zoneId: 'P'),
        ]).single;

        expect(group.zoneId, 'P');
      },
    );

    test('sorts groups by public name and then group id', () {
      final groups = groupStops([
        _stop(id: 'U2Z1', name: 'Flora', parentStationId: 'U2S1'),
        _stop(id: 'U1Z1', name: 'Anděl', parentStationId: 'U1S1'),
        _stop(id: 'U3Z1', name: 'Anděl', parentStationId: 'U3S1'),
      ]);

      expect(groups.map((group) => group.id), ['U1S1', 'U3S1', 'U2S1']);
      expect(groups.map((group) => group.name), ['Anděl', 'Anděl', 'Flora']);
    });
  });
}

Stop _stop({
  required String id,
  required String name,
  String? parentStationId,
  String? platformCode,
  String zoneId = 'P',
  double latitude = 50.0,
  double longitude = 14.0,
}) {
  return Stop(
    id: id,
    name: name,
    parentStationId: parentStationId,
    platformCode: platformCode,
    zoneId: zoneId,
    locationType: 0,
    latitude: latitude,
    longitude: longitude,
  );
}
