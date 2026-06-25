import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/network/golemio_query_parameters.dart';

void main() {
  group('GolemioQueryParameters', () {
    test('serializes regular and nullable parameters deterministically', () {
      final parameters = GolemioQueryParameters.fromMap({
        'limit': '500',
        'offset': '1000',
        'ignored': null,
      });

      expect(parameters.encoded, 'limit=500&offset=1000');
      expect(
        parameters.appendToPath('/v2/gtfs/stops'),
        '/v2/gtfs/stops?limit=500&offset=1000',
      );
    });

    test(
      'serializes repeated square-bracket keys without collapsing values',
      () {
        final parameters = GolemioQueryParameters.fromEntries(
          const [
            GolemioQueryParameter('names[]', 'Flora'),
            GolemioQueryParameter('names[]', 'Anděl'),
            GolemioQueryParameter('ids[]', 'U118Z101P'),
          ],
        );

        expect(
          parameters.encoded,
          'names[]=Flora&names[]=And%C4%9Bl&ids[]=U118Z101P',
        );
      },
    );

    test('appends to paths that already contain a query string', () {
      final parameters = GolemioQueryParameters.fromMap({'offset': '500'});

      expect(
        parameters.appendToPath('/v2/gtfs/stops?limit=500'),
        '/v2/gtfs/stops?limit=500&offset=500',
      );
    });
  });
}
