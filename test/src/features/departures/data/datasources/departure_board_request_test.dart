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
      expect(request.effectiveLimit, departureBoardDefaultLimit);
      expect(
        request.effectiveMinutesAfter,
        departureBoardDefaultMinutesAfter,
      );
      expect(
        request.effectiveMinutesBefore,
        departureBoardDefaultMinutesBefore,
      );
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

    test('serializes optional API window parameters when set', () {
      final request = DepartureBoardRequest(
        stopIds: ['U717Z5P'],
        limit: 30,
        minutesAfter: 360,
        minutesBefore: -359,
      );

      expect(request.effectiveLimit, 30);
      expect(request.effectiveMinutesAfter, 360);
      expect(request.effectiveMinutesBefore, -359);
      expect(request.queryParameters.toSingleValueMap(), {
        'stopIds': '{"0":["U717Z5P"]}',
        'limit': '30',
        'minutesAfter': '360',
        'minutesBefore': '-359',
      });
      expect(
        request.queryParameters.encoded,
        'stopIds=%7B%220%22%3A%5B%22U717Z5P%22%5D%7D&'
        'limit=30&minutesAfter=360&minutesBefore=-359',
      );
    });

    test('serializes multiple stop ID groups deterministically', () {
      final request = DepartureBoardRequest.grouped(
        stopIdGroups: [
          ['U717Z5P'],
          [' U718Z5P ', 'U719Z5P'],
        ],
      );

      expect(request.stopIds, ['U717Z5P', 'U718Z5P', 'U719Z5P']);
      expect(request.stopIdGroups, [
        ['U717Z5P'],
        ['U718Z5P', 'U719Z5P'],
      ]);
      expect(
        request.stopIdsValue,
        '{"0":["U717Z5P"],"1":["U718Z5P","U719Z5P"]}',
      );
    });

    test('rejects empty stop ID input after trimming', () {
      expect(
        () => DepartureBoardRequest(stopIds: const []),
        throwsArgumentError,
      );
      expect(
        () => DepartureBoardRequest(stopIds: const [' ', '']),
        throwsArgumentError,
      );
    });

    test('rejects too many stop ID groups', () {
      final groups = List<List<String>>.generate(
        departureBoardMaxGroups + 1,
        (index) => ['U$index'],
      );

      expect(
        () => DepartureBoardRequest.grouped(stopIdGroups: groups),
        throwsRangeError,
      );
    });

    test('rejects too many stop IDs in one group', () {
      final stopIds = List<String>.generate(
        departureBoardMaxStopsPerGroup + 1,
        (index) => 'U$index',
      );

      expect(
        () => DepartureBoardRequest(stopIds: stopIds),
        throwsRangeError,
      );
    });

    test('rejects too many combined stop IDs', () {
      final groups = List<List<String>>.generate(
        26,
        (index) => ['U${index}A', 'U${index}B'],
      );

      expect(
        () => DepartureBoardRequest.grouped(stopIdGroups: groups),
        throwsRangeError,
      );
    });

    test('rejects invalid limit values', () {
      expect(
        () => DepartureBoardRequest(stopIds: const ['U717Z5P'], limit: 0),
        throwsRangeError,
      );
      expect(
        () => DepartureBoardRequest(
          stopIds: const ['U717Z5P'],
          limit: departureBoardMaxLimit + 1,
        ),
        throwsRangeError,
      );
    });

    test('rejects invalid minutesAfter values', () {
      expect(
        () => DepartureBoardRequest(
          stopIds: const ['U717Z5P'],
          minutesAfter: -1,
        ),
        throwsRangeError,
      );
      expect(
        () => DepartureBoardRequest(
          stopIds: const ['U717Z5P'],
          minutesAfter: departureBoardMaxMinutesAfter + 1,
        ),
        throwsRangeError,
      );
    });

    test('rejects invalid minutesBefore values', () {
      expect(
        () => DepartureBoardRequest(
          stopIds: const ['U717Z5P'],
          minutesBefore: departureBoardMinMinutesBefore - 1,
        ),
        throwsRangeError,
      );
      expect(
        () => DepartureBoardRequest(
          stopIds: const ['U717Z5P'],
          minutesBefore: departureBoardMaxMinutesBefore + 1,
        ),
        throwsRangeError,
      );
    });
  });
}
