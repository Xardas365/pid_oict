import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/config/app_config.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/network/dio_provider.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';
import 'package:pid_oict/src/core/network/golemio_query_parameters.dart';

void main() {
  group('GolemioApiClient', () {
    test('throws a controlled error when token is missing', () async {
      final adapter = _FakeDioAdapter((_) {
        fail('Dio adapter should not be called without a token.');
      });
      final client = _client(apiToken: '', adapter: adapter);

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.missingToken,
          ),
        ),
      );
    });

    test('sends the configured token header and decodes JSON', () async {
      final adapter = _FakeDioAdapter((_) async {
        return _jsonResponse('{"ok":true}');
      });
      final client = _client(apiToken: 'configured-value', adapter: adapter);

      final result = await client.getJson(
        '/v2/gtfs/stops',
        queryParameters: GolemioQueryParameters.fromMap({'limit': '1'}),
      );

      expect(result, {'ok': true});
      expect(adapter.requests, hasLength(1));
      expect(
        adapter.requests.single.uri.toString(),
        '$golemioBaseUrl/v2/gtfs/stops?limit=1',
      );
      expect(
        adapter.requests.single.headers['x-access-token'],
        'configured-value',
      );
      expect(adapter.requests.single.headers['accept'], 'application/json');
    });

    test(
      'serializes repeated query keys through the shared query encoder',
      () async {
        final adapter = _FakeDioAdapter((_) async {
          return _jsonResponse('{"ok":true}');
        });
        final client = _client(apiToken: 'configured-value', adapter: adapter);

        await client.getJson(
          '/v2/gtfs/stops',
          queryParameters: GolemioQueryParameters.fromEntries(
            const [
              GolemioQueryParameter('names[]', 'Flora'),
              GolemioQueryParameter('names[]', 'Anděl'),
              GolemioQueryParameter('limit', '100'),
            ],
          ),
        );

        expect(
          adapter.requests.single.uri.toString(),
          '$golemioBaseUrl/v2/gtfs/stops?'
          'names%5B%5D=Flora&'
          'names%5B%5D=And%C4%9Bl&'
          'limit=100',
        );
      },
    );

    test('does not log API token in debug logs', () async {
      final logs = <String>[];
      final adapter = _FakeDioAdapter((_) async {
        return _jsonResponse('{"ok":true,"sample":"Andel"}');
      });
      final dio = createGolemioDio(enableLogging: true, logger: logs.add)
        ..httpClientAdapter = adapter;
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'secret-token-value'),
        dio: dio,
      );

      await client.getJson(
        '/v2/gtfs/stops',
        queryParameters: GolemioQueryParameters.fromMap({'limit': '1'}),
      );

      final combinedLogs = logs.join('\n');

      expect(logs, isNotEmpty);
      expect(
        combinedLogs,
        contains('========== GOLEMIO HTTP REQUEST START =========='),
      );
      expect(combinedLogs, contains('method: GET'));
      expect(combinedLogs, contains('/v2/gtfs/stops?limit=1'));
      expect(combinedLogs, contains('query:'));
      expect(combinedLogs, contains('"limit": "1"'));
      expect(combinedLogs, contains('body:'));
      expect(combinedLogs, contains('<empty>'));
      expect(
        combinedLogs,
        contains('========== GOLEMIO HTTP REQUEST END ============'),
      );
      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP RESPONSE START ========='),
      );
      expect(combinedLogs, contains('outcome: success'));
      expect(combinedLogs, contains('status: 200'));
      expect(combinedLogs, contains('"ok": true'));
      expect(combinedLogs, contains('"sample": "Andel"'));
      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP RESPONSE END ==========='),
      );
      expect(combinedLogs, isNot(contains('secret-token-value')));
      expect(combinedLogs, isNot(contains('x-access-token')));
    });

    test('logs failed HTTP status without leaking token', () async {
      final logs = <String>[];
      final adapter = _FakeDioAdapter((_) async {
        return _jsonResponse('{"error":"Unauthorized"}', 401);
      });
      final dio = createGolemioDio(enableLogging: true, logger: logs.add)
        ..httpClientAdapter = adapter;
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'secret-token-value'),
        dio: dio,
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(isA<AppException>()),
      );

      final combinedLogs = logs.join('\n');

      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP RESPONSE START ========='),
      );
      expect(combinedLogs, contains('outcome: failure'));
      expect(combinedLogs, contains('status: 401'));
      expect(combinedLogs, contains('/v2/gtfs/stops'));
      expect(combinedLogs, contains('body:'));
      expect(combinedLogs, contains('"error": "Unauthorized"'));
      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP RESPONSE END ==========='),
      );
      expect(combinedLogs, isNot(contains('secret-token-value')));
      expect(combinedLogs, isNot(contains('x-access-token')));
    });

    test('redacts sensitive request query, headers, and body logs', () async {
      final logs = <String>[];
      final adapter = _FakeDioAdapter((_) async {
        return _jsonResponse('{"ok":true}');
      });
      final dio = createGolemioDio(enableLogging: true, logger: logs.add)
        ..httpClientAdapter = adapter;

      await dio.post<dynamic>(
        '/v2/debug',
        queryParameters: {
          'accessToken': 'hidden-query-value',
          'stopIds': '{"0":["U123Z1"]}',
        },
        data: {
          'name': 'Andel',
          'apiToken': 'hidden-body-token',
          'nested': {'password': 'hidden-password'},
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'x-access-token': 'hidden-header-token',
          },
        ),
      );

      final combinedLogs = logs.join('\n');

      expect(combinedLogs, contains('method: POST'));
      expect(combinedLogs, contains('/v2/debug?accessToken=%3Credacted%3E'));
      expect(combinedLogs, contains('"accessToken": "<redacted>"'));
      expect(combinedLogs, contains('"stopIds": {'));
      expect(combinedLogs, contains('"0": ['));
      expect(combinedLogs, contains('"U123Z1"'));
      expect(combinedLogs, contains('"name": "Andel"'));
      expect(combinedLogs, contains('"apiToken": "<redacted>"'));
      expect(combinedLogs, contains('"password": "<redacted>"'));
      expect(combinedLogs, isNot(contains('hidden-query-value')));
      expect(combinedLogs, isNot(contains('hidden-body-token')));
      expect(combinedLogs, isNot(contains('hidden-password')));
      expect(combinedLogs, isNot(contains('hidden-header-token')));
      expect(combinedLogs, isNot(contains('x-access-token')));
    });

    test('logs transport failures without leaking token', () async {
      final logs = <String>[];
      final adapter = _FakeDioAdapter((options) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      });
      final dio = createGolemioDio(enableLogging: true, logger: logs.add)
        ..httpClientAdapter = adapter;
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'secret-token-value'),
        dio: dio,
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(isA<AppException>()),
      );

      final combinedLogs = logs.join('\n');

      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP FAILURE START =========='),
      );
      expect(combinedLogs, contains('status: -'));
      expect(combinedLogs, contains('type: connectionError'));
      expect(combinedLogs, contains('/v2/gtfs/stops'));
      expect(combinedLogs, contains('responseBody:'));
      expect(combinedLogs, contains('<empty>'));
      expect(
        combinedLogs,
        contains('========= GOLEMIO HTTP FAILURE END ============'),
      );
      expect(combinedLogs, isNot(contains('secret-token-value')));
      expect(combinedLogs, isNot(contains('x-access-token')));
    });

    test('distinguishes unauthorized responses', () async {
      for (final statusCode in [401, 403]) {
        final client = _client(
          apiToken: 'configured-value',
          adapter: _FakeDioAdapter((_) async {
            return _jsonResponse('{"error":"Unauthorized"}', statusCode);
          }),
        );

        await expectLater(
          client.getJson('/v2/gtfs/stops'),
          throwsA(
            isA<AppException>()
                .having(
                  (error) => error.type,
                  'type',
                  AppExceptionType.unauthorized,
                )
                .having((error) => error.statusCode, 'statusCode', statusCode),
          ),
        );
      }
    });

    test('maps not found responses', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((_) async {
          return _jsonResponse('{"error":"Not found"}', 404);
        }),
      );

      await expectLater(
        client.getJson('/v2/missing'),
        throwsA(
          isA<AppException>()
              .having((error) => error.type, 'type', AppExceptionType.notFound)
              .having((error) => error.statusCode, 'statusCode', 404),
        ),
      );
    });

    test(
      'can treat 404 empty JSON list as an empty result when opted in',
      () async {
        final client = _client(
          apiToken: 'configured-value',
          adapter: _FakeDioAdapter((_) async {
            return _jsonResponse('[]', 404);
          }),
        );

        final result = await client.getJson(
          '/v2/public/departureboards',
          notFoundEmptyListAsSuccess: true,
        );

        expect(result, isEmpty);
      },
    );

    test('maps server errors', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((_) async {
          return _jsonResponse('{"error":"Server error"}', 503);
        }),
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>()
              .having((error) => error.type, 'type', AppExceptionType.server)
              .having((error) => error.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('normalizes invalid JSON responses', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((_) async {
          return _plainResponse('not json');
        }),
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.invalidJson,
          ),
        ),
      );
    });

    test('normalizes empty responses', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((_) async {
          return _plainResponse('   ');
        }),
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.emptyResponse,
          ),
        ),
      );
    });

    test('normalizes network failures', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((options) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          );
        }),
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.network,
          ),
        ),
      );
    });

    test('normalizes timeout failures', () async {
      final client = _client(
        apiToken: 'configured-value',
        adapter: _FakeDioAdapter((options) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          );
        }),
      );

      await expectLater(
        client.getJson('/v2/gtfs/stops'),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppExceptionType.timeout,
          ),
        ),
      );
    });
  });
}

GolemioApiClient _client({
  required String apiToken,
  required _FakeDioAdapter adapter,
}) {
  final dio = createGolemioDio()..httpClientAdapter = adapter;

  return GolemioApiClient(
    config: AppConfig(apiToken: apiToken),
    dio: dio,
  );
}

ResponseBody _jsonResponse(String body, [int statusCode = 200]) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

ResponseBody _plainResponse(String body, [int statusCode = 200]) {
  return ResponseBody.fromString(body, statusCode);
}

class _FakeDioAdapter implements HttpClientAdapter {
  _FakeDioAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
