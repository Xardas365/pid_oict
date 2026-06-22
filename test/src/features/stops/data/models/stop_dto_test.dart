import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/models/stop_dto.dart';

void main() {
  group('StopDto', () {
    test('parses required fields and GeoJSON coordinates', () {
      final dto = StopDto.fromJson({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [14.42076, 50.08804],
        },
        'properties': {
          'stop_id': 'U123Z1',
          'stop_name': 'Staromestska',
          'platform_code': 'A',
        },
      });

      expect(dto, isNotNull);
      expect(dto!.id, 'U123Z1');
      expect(dto.name, 'Staromestska');
      expect(dto.platformCode, 'A');
      expect(dto.latitude, 50.08804);
      expect(dto.longitude, 14.42076);

      final stop = dto.toDomain();

      expect(stop.id, dto.id);
      expect(stop.name, dto.name);
      expect(stop.latitude, dto.latitude);
      expect(stop.longitude, dto.longitude);
    });

    test('tolerates missing optional fields', () {
      final dto = StopDto.fromJson({'stop_id': 'U456', 'stop_name': 'Andel'});

      expect(dto, isNotNull);
      expect(dto!.platformCode, isNull);
      expect(dto.latitude, isNull);
      expect(dto.longitude, isNull);
    });

    test('ignores invalid optional coordinates', () {
      final dto = StopDto.fromJson({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [200.0, 95.0],
        },
        'properties': {'stop_id': 'U456', 'stop_name': 'Andel'},
      });

      expect(dto, isNotNull);
      expect(dto!.id, 'U456');
      expect(dto.name, 'Andel');
      expect(dto.latitude, isNull);
      expect(dto.longitude, isNull);
    });

    test('rejects records without required fields', () {
      expect(StopDto.fromJson({'stop_id': 'U456'}), isNull);
      expect(StopDto.fromJson({'stop_name': 'Andel'}), isNull);
    });
  });
}
