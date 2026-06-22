import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';

class GolemioApiClient {
  GolemioApiClient({
    this.config = const AppConfig(),
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final AppConfig config;
  final Duration timeout;
  final http.Client _httpClient;
  final bool _ownsHttpClient;

  Future<Object?> getJson(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) async {
    final token = config.apiToken.trim();

    if (token.isEmpty) {
      throw const AppException(
        type: AppExceptionType.missingToken,
        message:
            'Golemio API token is missing. Run the app with '
            '--dart-define=GOLEMIO_API_TOKEN=your_token_here.',
      );
    }

    final uri = _buildUri(path, queryParameters);

    late http.Response response;
    try {
      response = await _httpClient
          .get(
            uri,
            headers: {'accept': 'application/json', 'x-access-token': token},
          )
          .timeout(timeout);
    } on TimeoutException catch (error) {
      throw AppException(
        type: AppExceptionType.timeout,
        message: 'The Golemio API request timed out.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'The Golemio API request failed due to a network error.',
        cause: error,
      );
    }

    _throwForStatus(response.statusCode);

    final body = response.body.trim();
    if (body.isEmpty) {
      throw AppException(
        type: AppExceptionType.emptyResponse,
        message: 'The Golemio API returned an empty response.',
        statusCode: response.statusCode,
      );
    }

    try {
      return jsonDecode(body) as Object?;
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.invalidJson,
        message: 'The Golemio API returned invalid JSON.',
        statusCode: response.statusCode,
        cause: error,
      );
    }
  }

  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  Uri _buildUri(String path, Map<String, String?> queryParameters) {
    final baseUri = Uri.parse(config.baseUrl);
    final uri = baseUri.resolve(path);
    final filteredQueryParameters = <String, String>{
      for (final entry in queryParameters.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    if (filteredQueryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...filteredQueryParameters},
    );
  }

  void _throwForStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    if (statusCode == 400) {
      throw AppException(
        type: AppExceptionType.badRequest,
        message: 'The Golemio API rejected the request.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      throw AppException(
        type: AppExceptionType.unauthorized,
        message: 'The Golemio API token is invalid or unauthorized.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      throw AppException(
        type: AppExceptionType.notFound,
        message: 'The requested Golemio API resource was not found.',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 500) {
      throw AppException(
        type: AppExceptionType.server,
        message: 'The Golemio API is currently unavailable.',
        statusCode: statusCode,
      );
    }

    throw AppException(
      type: AppExceptionType.unexpectedStatus,
      message: 'The Golemio API returned an unexpected status.',
      statusCode: statusCode,
    );
  }
}
