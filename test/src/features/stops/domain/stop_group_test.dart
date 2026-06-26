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

    test('groups stop points with the same name and close coordinates', () {
      final group = groupStops([
        _stop(
          id: 'U1Z1',
          name: 'Vltavská',
          parentStationId: 'U1S1',
          platformCode: 'A',
          latitude: 50.09911,
          longitude: 14.43828,
        ),
        _stop(
          id: 'U2Z1',
          name: 'Vltavská',
          parentStationId: 'U2S1',
          platformCode: 'B',
          latitude: 50.09944,
          longitude: 14.43872,
        ),
      ]).single;

      expect(group.id, 'logical:vltavská:U1S1');
      expect(group.name, 'Vltavská');
      expect(group.parentStationIds, ['U1S1', 'U2S1']);
      expect(group.legacyGroupIds, ['U1S1', 'U2S1']);
      expect(group.stopIds, ['U1Z1', 'U2Z1']);
      expect(group.platformCodes, ['A', 'B']);
    });

    test('keeps close same-name stop chains in one logical group', () {
      final group = groupStops([
        _stop(
          id: 'U1Z1',
          name: 'Anděl',
          platformCode: 'A',
          latitude: 50.07100,
          longitude: 14.40100,
        ),
        _stop(
          id: 'U1Z2',
          name: 'Anděl',
          platformCode: 'B',
          latitude: 50.07350,
          longitude: 14.40100,
        ),
        _stop(
          id: 'U1Z3',
          name: 'Anděl',
          platformCode: 'C',
          latitude: 50.07600,
          longitude: 14.40100,
        ),
      ]).single;

      expect(group.stopIds, ['U1Z1', 'U1Z2', 'U1Z3']);
      expect(group.platformCodes, ['A', 'B', 'C']);
    });

    test('does not merge stops with the same name when they are far apart', () {
      final groups = groupStops([
        _stop(
          id: 'U1Z1',
          name: 'Nová Ves',
          parentStationId: 'U1S1',
        ),
        _stop(
          id: 'U2Z1',
          name: 'Nová Ves',
          parentStationId: 'U2S1',
          latitude: 49.1,
          longitude: 15.1,
        ),
      ]);

      expect(groups, hasLength(2));
      expect(groups.map((group) => group.id), ['U1S1', 'U2S1']);
    });

    test('keeps same-name stops without parent separate when far apart', () {
      final groups = groupStops([
        _stop(id: 'U1Z1', name: 'Lhota'),
        _stop(id: 'U2Z1', name: 'Lhota', latitude: 49.1, longitude: 15.1),
      ]);

      expect(groups, hasLength(2));
      expect(groups.map((group) => group.id), [
        'logical:lhota:U1Z1',
        'logical:lhota:U2Z1',
      ]);
      for (final group in groups) {
        expect(group.legacyGroupIds, ['name:lhota']);
      }
    });

    test('groups Vltavská-like metro, tram and bus stops logically', () {
      final group = groupStops([
        _stop(
          id: 'U100Z1',
          name: 'Vltavská',
          parentStationId: 'U100S1',
          platformCode: 'M',
          latitude: 50.09910,
          longitude: 14.43830,
        ),
        _stop(
          id: 'U200Z1',
          name: 'Vltavská',
          parentStationId: 'U200S1',
          platformCode: 'A',
          latitude: 50.09935,
          longitude: 14.43860,
        ),
        _stop(
          id: 'U300Z1',
          name: 'Vltavská',
          parentStationId: 'U300S1',
          platformCode: 'B',
          latitude: 50.09948,
          longitude: 14.43890,
        ),
      ]).single;

      expect(group.name, 'Vltavská');
      expect(group.stopIds, ['U100Z1', 'U200Z1', 'U300Z1']);
      expect(group.platformCodes, ['A', 'B', 'M']);
      expect(group.parentStationIds, ['U100S1', 'U200S1', 'U300S1']);
    });

    test('chooses deterministic display name', () {
      final group = groupStops([
        _stop(id: 'U1Z2', name: 'anděl', parentStationId: 'U1S1'),
        _stop(id: 'U1Z1', name: 'Anděl', parentStationId: 'U1S1'),
      ]).single;

      expect(group.name, 'Anděl');
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
          _stop(id: 'U1Z2', name: 'Anděl'),
          _stop(id: 'U1Z3', name: 'Anděl'),
        ]).single;

        expect(group.zoneId, 'P');
      },
    );

    test('sorts groups by public name and then group id', () {
      final groups = groupStops([
        _stop(id: 'U2Z1', name: 'Flora', parentStationId: 'U2S1'),
        _stop(id: 'U1Z1', name: 'Anděl', parentStationId: 'U1S1'),
        _stop(
          id: 'U3Z1',
          name: 'Anděl',
          parentStationId: 'U3S1',
          latitude: 49.1,
          longitude: 15.1,
        ),
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
