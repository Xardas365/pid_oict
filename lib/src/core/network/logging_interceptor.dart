import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _requestStopwatchKey = 'golemio_request_stopwatch';

class DebugLoggingInterceptor extends Interceptor {
  DebugLoggingInterceptor({void Function(String message)? logger})
    : _logger = logger ?? _debugLogger;

  final void Function(String message) _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_requestStopwatchKey] = Stopwatch()..start();
    _logger('HTTP ${options.method} ${_safeUrl(options)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger(
      'HTTP ${response.statusCode ?? '-'} ${_durationLabel(response.requestOptions)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger(
      'HTTP error type=${err.type.name} status=${err.response?.statusCode ?? '-'} ${_durationLabel(err.requestOptions)}',
    );
    handler.next(err);
  }
}

String _safeUrl(RequestOptions options) {
  final uri = options.uri;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  ).toString();
}

String _durationLabel(RequestOptions options) {
  final stopwatch = options.extra[_requestStopwatchKey];
  if (stopwatch is! Stopwatch) {
    return 'duration=-';
  }

  stopwatch.stop();
  return 'duration=${stopwatch.elapsedMilliseconds}ms';
}

void _debugLogger(String message) {
  debugPrint(message);
}
