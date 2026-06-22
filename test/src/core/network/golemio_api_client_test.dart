import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pid_oict/src/core/config/app_config.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';

void main() {
  group('GolemioApiClient', () {
    test('throws a controlled error when token is missing', () async {
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: ''),
        httpClient: MockClient((_) {
          fail('HTTP client should not be called without a token.');
        }),
      );

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
      late http.Request capturedRequest;
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response('{"ok":true}', 200);
        }),
      );

      final result = await client.getJson(
        '/v2/gtfs/stops',
        queryParameters: {'limit': '1'},
      );

      expect(result, {'ok': true});
      expect(
        capturedRequest.url.toString(),
        '$golemioBaseUrl/v2/gtfs/stops?limit=1',
      );
      expect(capturedRequest.headers['x-access-token'], 'configured-value');
      expect(capturedRequest.headers['accept'], 'application/json');
    });

    test('distinguishes unauthorized responses', () async {
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        httpClient: MockClient((_) async => http.Response('Unauthorized', 401)),
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
              .having((error) => error.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('normalizes invalid JSON responses', () async {
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        httpClient: MockClient((_) async => http.Response('not json', 200)),
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
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        httpClient: MockClient((_) async => http.Response('   ', 200)),
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
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        httpClient: MockClient((_) async {
          throw http.ClientException('offline');
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
      final client = GolemioApiClient(
        config: const AppConfig(apiToken: 'configured-value'),
        timeout: const Duration(milliseconds: 1),
        httpClient: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));

          return http.Response('{"ok":true}', 200);
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
