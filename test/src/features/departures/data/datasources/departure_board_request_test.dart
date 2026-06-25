import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/features/departures/data/datasources/departures_remote_data_source.dart';

void main() {
  group('DepartureBoardRequest', () {
    test('builds public departure board endpoint and stopIds query', () {
      final request = DepartureBoardRequest(
        stopIds: [' U717Z5P ', '', 'U718Z5P'],
      );

      expect(request.path, '/v2/public/departureboards');
      expect(request.notFoundEmptyListAsSuccess, isTrue);
      expect(request.stopIds, ['U717Z5P', 'U718Z5P']);
      expect(request.queryParameters.toSingleValueMap(), {
        'stopIds': '{"0":["U717Z5P","U718Z5P"]}',
      });
      expect(
        request.queryParameters.encoded,
        'stopIds=%7B%220%22%3A%5B%22U717Z5P%22%2C%22U718Z5P%22%5D%7D',
      );
      expect(
        request.queryParameters.appendToPath(request.path),
        '/v2/public/departureboards?'
        'stopIds=%7B%220%22%3A%5B%22U717Z5P%22%2C%22U718Z5P%22%5D%7D',
      );
      expect(request.queryParameters.encoded, isNot(contains('stopIds[]')));
    });

    test('keeps grouped stopIds JSON structure stable', () {
      final request = DepartureBoardRequest(
        stopIds: ['U118Z101P', 'U118Z102P', 'U118Z103P'],
      );

      expect(departureBoardsStopFilterParameter, 'stopIds');
      expect(
        request.stopIdsValue,
        '{"0":["U118Z101P","U118Z102P","U118Z103P"]}',
      );
      expect(
        request.queryParameters.toSingleValueMap(),
        {'stopIds': '{"0":["U118Z101P","U118Z102P","U118Z103P"]}'},
      );
    });
  });
}
