import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/domain/search/stop_search_alias_builder.dart';
import 'package:pid_oict/src/features/stops/domain/stop.dart';
import 'package:pid_oict/src/features/stops/domain/stop_group.dart';

void main() {
  group('StopSearchAliasBuilder', () {
    const builder = StopSearchAliasBuilder();

    test('includes parent station aliases from child stops', () {
      final group = StopGroup.single(
        const Stop(
          id: 'U202Z101P',
          name: 'Hlavní nádraží',
          parentStationId: 'U202S1',
          locationType: 0,
          latitude: 50,
          longitude: 14,
          searchAliases: ['Praha hlavní nádraží'],
        ),
      );

      final aliases = builder.buildAliases(group);

      expect(aliases, contains('Hlavní nádraží'));
      expect(aliases, contains('Praha hlavní nádraží'));
    });
  });
}
