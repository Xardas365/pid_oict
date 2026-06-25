import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/gtfs_stops_query_parameters.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';

void main() {
  group('GTFS stops query parameters', () {
    test('serializes limit and offset', () {
      expect(
        gtfsStopsPathWithQuery(const GtfsStopsQuery(limit: 500, offset: 1000)),
        '/v2/gtfs/stops?limit=500&offset=1000',
      );
    });

    test('serializes square-bracket array parameters explicitly', () {
      const query = GtfsStopsQuery(
        limit: 100,
        offset: 0,
        names: ['Flora', 'Anděl'],
        ids: ['U118Z101P'],
        aswIds: ['1833_12'],
        cisIds: [12345, 67890],
      );

      expect(
        gtfsStopsPathWithQuery(query),
        '/v2/gtfs/stops?'
        'names[]=Flora&'
        'names[]=And%C4%9Bl&'
        'ids[]=U118Z101P&'
        'aswIds[]=1833_12&'
        'cisIds[]=12345&'
        'cisIds[]=67890&'
        'limit=100&'
        'offset=0',
      );
    });

    test('omits blank array values and absent scalar values', () {
      expect(
        gtfsStopsPathWithQuery(
          const GtfsStopsQuery(names: ['  ', 'Flora'], ids: []),
        ),
        '/v2/gtfs/stops?names[]=Flora',
      );
    });
  });
}
