import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_visibility.dart';

void main() {
  group('stop visibility', () {
    test('accepts public PID stop platform records', () {
      expect(isUserFacingStop(_publicStop()), isTrue);
    });

    test('rejects records without public stop requirements', () {
      expect(isUserFacingStop(_publicStop(id: 'T53297')), isFalse);
      expect(isUserFacingStop(_publicStop(name: '')), isFalse);
      expect(isUserFacingStop(_publicStop(locationType: 1)), isFalse);
      expect(isUserFacingStop(_publicStop(zoneId: null)), isFalse);
      expect(isUserFacingStop(_publicStop(latitude: null)), isFalse);
      expect(isUserFacingStop(_publicStop(longitude: null)), isFalse);
      expect(isUserFacingStop(_publicStop(latitude: 95)), isFalse);
      expect(isUserFacingStop(_publicStop(longitude: 200)), isFalse);
    });

    test('detects technical infrastructure stop names conservatively', () {
      expect(isTechnicalStopName('hr.VUSC Praha'), isTrue);
      expect(isTechnicalStopName('Km 12,400'), isTrue);
      expect(isTechnicalStopName('km 8,1'), isTrue);
      expect(isTechnicalStopName('Odb Balabenka'), isTrue);
      expect(isTechnicalStopName('vl. v km 12,4'), isTrue);
      expect(isTechnicalStopName('Kolín výh.č.1'), isTrue);
      expect(isTechnicalStopName('vjezd.náv Praha'), isTrue);
      expect(isTechnicalStopName('odj.náv Praha'), isTrue);
      expect(isTechnicalStopName('Praha náv. 1'), isTrue);

      expect(isTechnicalStopName('Kmetineves'), isFalse);
      expect(isTechnicalStopName('Odborářů'), isFalse);
      expect(isTechnicalStopName('Nádraží Veleslavín'), isFalse);
    });

    test('filters and sorts user-facing stops by public name', () {
      final stops = sortedUserFacingStops([
        _publicStop(id: 'U2Z1'),
        _publicStop(name: 'Anděl', id: 'U1Z1'),
        _publicStop(name: 'vl. v km 12,4', id: 'T53297'),
        _publicStop(name: 'Kolín výh.č.1', id: 'U3Z1'),
      ]);

      expect(stops.map((stop) => stop.name), ['Anděl', 'Flora']);
    });
  });
}

Stop _publicStop({
  String id = 'U123Z1',
  String name = 'Flora',
  String? zoneId = 'P',
  int? locationType = 0,
  double? latitude = 50.07827,
  double? longitude = 14.4633,
}) {
  return Stop(
    id: id,
    name: name,
    zoneId: zoneId,
    locationType: locationType,
    latitude: latitude,
    longitude: longitude,
  );
}
