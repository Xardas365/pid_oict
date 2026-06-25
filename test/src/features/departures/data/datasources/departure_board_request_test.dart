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
      expect(request.queryParameters, {
        'stopIds': '{"0":["U717Z5P","U718Z5P"]}',
      });
    });
  });
}
