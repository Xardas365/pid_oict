import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/stops/data/datasources/stops_remote_data_source.dart';
import 'package:pid_oict/src/features/stops/domain/gtfs_stops_query.dart';

void main() {
  group('StopsRequest', () {
    test('builds GTFS stops endpoint with limit and offset', () {
      const request = StopsRequest(GtfsStopsQuery(limit: 500, offset: 1000));

      expect(request.path, '/v2/gtfs/stops?limit=500&offset=1000');
      expect(request.queryParameters, isEmpty);
    });

    test('builds GTFS stops endpoint with array query parameters', () {
      const request = StopsRequest(
        GtfsStopsQuery(
          names: ['Flora'],
          ids: ['U118Z101P'],
          aswIds: ['1833_12'],
          cisIds: [12345],
          limit: 100,
          offset: 0,
        ),
      );

      expect(
        request.path,
        '/v2/gtfs/stops?'
        'names[]=Flora&'
        'ids[]=U118Z101P&'
        'aswIds[]=1833_12&'
        'cisIds[]=12345&'
        'limit=100&'
        'offset=0',
      );
      expect(request.queryParameters, isEmpty);
    });
  });
}
