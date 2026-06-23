import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/config/app_config.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/network/dio_provider.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';

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
        queryParameters: {'limit': '1'},
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

    test('does not log API token in debug logs', () async {
      final logs = <String>[];
      final adapter = _FakeDioAdapter((_) async {
        return _jsonResponse('{"ok":true}');
      });
      final dio = createGolemioDio(enableLogging: true, logger: logs.add)
        ..httpClientAdapter = adapter;
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'secret-token-value'),
        dio: dio,
      );

      await client.getJson('/v2/gtfs/stops', queryParameters: {'limit': '1'});

      expect(logs, isNotEmpty);
      expect(logs.join('\n'), isNot(contains('secret-token-value')));
      expect(logs.join('\n'), isNot(contains('x-access-token')));
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
  final dio = createGolemioDio(enableLogging: false)
    ..httpClientAdapter = adapter;

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
