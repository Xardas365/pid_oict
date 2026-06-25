import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'dio_provider.dart';
import 'golemio_query_parameters.dart';

class GolemioApiClient {
  GolemioApiClient({
    this.config = const AppConfig(),
    Dio? dio,
    this.timeout = const Duration(seconds: 20),
    bool enableLogging = kDebugMode,
    void Function(String message)? logger,
  }) : _dio =
           dio ??
           createGolemioDio(
             baseUrl: config.baseUrl,
             timeout: timeout,
             enableLogging: enableLogging,
             logger: logger,
           ),
       _ownsDio = dio == null;

  final AppConfig config;
  final Duration timeout;
  final Dio _dio;
  final bool _ownsDio;

  Future<Object?> getJson(
    String path, {
    GolemioQueryParameters queryParameters =
        const GolemioQueryParameters.empty(),
    bool notFoundEmptyListAsSuccess = false,
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

    late Response<String> response;
    try {
      response = await _dio.get<String>(
        queryParameters.appendToPath(path),
        options: Options(
          headers: {'accept': 'application/json', 'x-access-token': token},
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (error) {
      throw _exceptionForDioError(error);
    }

    final body = response.data?.trim() ?? '';

    if (notFoundEmptyListAsSuccess &&
        response.statusCode == 404 &&
        _isEmptyJsonList(body)) {
      return <Object?>[];
    }

    _throwForStatus(response.statusCode);

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

  bool _isEmptyJsonList(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is List && decoded.isEmpty;
    } on FormatException {
      return false;
    }
  }

  void close() {
    if (_ownsDio) {
      _dio.close(force: true);
    }
  }

  AppException _exceptionForDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode != null) {
      return _exceptionForStatus(statusCode, cause: error);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => AppException(
        type: AppExceptionType.timeout,
        message: 'The Golemio API request timed out.',
        cause: error,
      ),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.unknown => AppException(
        type: AppExceptionType.network,
        message: 'The Golemio API request failed due to a network error.',
        cause: error,
      ),
      DioExceptionType.badResponse => _exceptionForStatus(
        error.response?.statusCode,
        cause: error,
      ),
    };
  }

  void _throwForStatus(int? statusCode) {
    if (statusCode == null) {
      throw _exceptionForStatus(null);
    }

    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    throw _exceptionForStatus(statusCode);
  }

  AppException _exceptionForStatus(int? statusCode, {Object? cause}) {
    if (statusCode == null) {
      return AppException(
        type: AppExceptionType.unexpectedStatus,
        message: 'The Golemio API returned an unexpected status.',
        cause: cause,
      );
    }

    if (statusCode == 400) {
      return AppException(
        type: AppExceptionType.badRequest,
        message: 'The Golemio API rejected the request.',
        statusCode: statusCode,
        cause: cause,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      return AppException(
        type: AppExceptionType.unauthorized,
        message: 'The Golemio API token is invalid or unauthorized.',
        statusCode: statusCode,
        cause: cause,
      );
    }

    if (statusCode == 404) {
      return AppException(
        type: AppExceptionType.notFound,
        message: 'The requested Golemio API resource was not found.',
        statusCode: statusCode,
        cause: cause,
      );
    }

    if (statusCode >= 500) {
      return AppException(
        type: AppExceptionType.server,
        message: 'The Golemio API is currently unavailable.',
        statusCode: statusCode,
        cause: cause,
      );
    }

    return AppException(
      type: AppExceptionType.unexpectedStatus,
      message: 'The Golemio API returned an unexpected status.',
      statusCode: statusCode,
      cause: cause,
    );
  }
}
