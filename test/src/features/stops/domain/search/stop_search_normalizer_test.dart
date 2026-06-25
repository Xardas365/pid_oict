import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_normalizer.dart';

void main() {
  group('StopSearchNormalizer', () {
    const normalizer = StopSearchNormalizer();

    test('normalizes Czech diacritics for stop search', () {
      expect(normalizer.normalize('Budějovická'), 'budejovicka');
      expect(normalizer.normalize('Pankrác'), 'pankrac');
      expect(normalizer.normalize('Černý Most'), 'cerny most');
    });

    test('normalizes common station abbreviations', () {
      expect(normalizer.normalize('Praha hl.'), 'praha hlavni');
      expect(normalizer.normalize('hl. n.'), 'hlavni nadrazi');
      expect(normalizer.normalize('hl.n.'), 'hlavni nadrazi');
      expect(normalizer.normalize('Praha nadr.'), 'praha nadrazi');
    });

    test('removes dots, commas, and repeated whitespace', () {
      expect(
        normalizer.normalize('  Praha,  hl.   n. '),
        'praha hlavni nadrazi',
      );
    });
  });
}
