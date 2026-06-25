import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stop search architecture', () {
    test('domain search package does not import presentation code', () {
      final searchFiles =
          Directory(
            'lib/src/features/stops/domain/search',
          ).listSync().whereType<File>().where((file) {
            return file.path.endsWith('.dart');
          });

      for (final file in searchFiles) {
        final source = file.readAsStringSync();
        expect(
          source,
          isNot(contains('/presentation/')),
          reason: '${file.path} must not depend on presentation code.',
        );
        expect(
          source,
          isNot(contains('../../presentation/')),
          reason: '${file.path} must not depend on presentation code.',
        );
      }
    });
  });
}
