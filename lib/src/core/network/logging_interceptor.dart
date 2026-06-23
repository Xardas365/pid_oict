import 'dart:convert';

import 'package:dio/dio.dart';

import '../logging/golemio_debug_logger.dart';

const _requestStopwatchKey = 'golemio_request_stopwatch';
const _maxBodyPreviewLength = 1200;
const _requestBlockStart = '========== GOLEMIO HTTP REQUEST START ==========';
const _requestBlockEnd = '========== GOLEMIO HTTP REQUEST END ============';
const _responseBlockStart = '========= GOLEMIO HTTP RESPONSE START =========';
const _responseBlockEnd = '========= GOLEMIO HTTP RESPONSE END ===========';
const _failureBlockStart = '========= GOLEMIO HTTP FAILURE START ==========';
const _failureBlockEnd = '========= GOLEMIO HTTP FAILURE END ============';

class DebugLoggingInterceptor extends Interceptor {
  DebugLoggingInterceptor({void Function(String message)? logger})
    : _logger = logger ?? logGolemioDebug;

  final void Function(String message) _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_requestStopwatchKey] = Stopwatch()..start();
    _logger(_requestLog(options));
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final bodySize = _responseBodySize(response.data);
    final statusCode = response.statusCode;
    final outcome = _isSuccessStatus(statusCode) ? 'success' : 'failure';
    _logger(_responseLog(response, outcome: outcome, bodySize: bodySize));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger(_failureLog(err));
    handler.next(err);
  }
}

bool _isSuccessStatus(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 300;
}

String _requestLog(RequestOptions options) {
  final buffer = StringBuffer()
    ..writeln(_requestBlockStart)
    ..writeln('method: ${options.method}')
    ..writeln('url: ${_safeUrl(options)}')
    ..writeln('path: ${options.path}')
    ..writeln('query:')
    ..writeln(_formatBlock(_safeQueryParameters(options.queryParameters)))
    ..writeln('headers:')
    ..writeln(_formatBlock(_safeHeaders(options.headers)))
    ..writeln('body:')
    ..writeln(_formatBlock(_safeBody(options.data)))
    ..write(_requestBlockEnd);

  return buffer.toString();
}

String _responseLog(
  Response<dynamic> response, {
  required String outcome,
  required int bodySize,
}) {
  final options = response.requestOptions;
  final buffer = StringBuffer()
    ..writeln(_responseBlockStart)
    ..writeln('outcome: $outcome')
    ..writeln('status: ${response.statusCode ?? '-'}')
    ..writeln('method: ${options.method}')
    ..writeln('url: ${_safeUrl(options)}')
    ..writeln(_durationLabel(options))
    ..writeln('bytes: $bodySize')
    ..writeln('body:')
    ..writeln(_formatBlock(_safeBody(response.data)))
    ..write(_responseBlockEnd);

  return buffer.toString();
}

String _failureLog(DioException err) {
  final response = err.response;
  final options = err.requestOptions;
  final buffer = StringBuffer()
    ..writeln(_failureBlockStart)
    ..writeln('status: ${response?.statusCode ?? '-'}')
    ..writeln('type: ${err.type.name}')
    ..writeln('method: ${options.method}')
    ..writeln('url: ${_safeUrl(options)}')
    ..writeln(_durationLabel(options))
    ..writeln('requestBody:')
    ..writeln(_formatBlock(_safeBody(options.data)))
    ..writeln('responseBody:')
    ..writeln(_formatBlock(_safeBody(response?.data)))
    ..write(_failureBlockEnd);

  return buffer.toString();
}

String _safeUrl(RequestOptions options) {
  final uri = options.uri;
  final safeQuery = _safeQueryString(uri);
  final baseUri = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  );

  return safeQuery.isEmpty ? baseUri.toString() : '$baseUri?$safeQuery';
}

String _safeQueryString(Uri uri) {
  final entries = <String>[];

  for (final entry in uri.queryParametersAll.entries) {
    for (final value in entry.value) {
      entries.add(
        '${Uri.encodeQueryComponent(entry.key)}='
        '${Uri.encodeQueryComponent(_safeQueryValue(entry.key, value))}',
      );
    }
  }

  return entries.join('&');
}

Map<String, Object?>? _safeQueryParameters(Map<String, dynamic> parameters) {
  final safeParameters = <String, Object?>{};

  for (final entry in parameters.entries) {
    safeParameters[entry.key] = _isSensitiveKey(entry.key)
        ? '<redacted>'
        : _safeBody(entry.value);
  }

  return safeParameters.isEmpty ? null : safeParameters;
}

String _safeQueryValue(String key, String value) {
  return _isSensitiveKey(key) ? '<redacted>' : value;
}

Map<String, String> _safeHeaders(Map<String, dynamic> headers) {
  final safeHeaders = <String, String>{};

  for (final entry in headers.entries) {
    final key = entry.key.toLowerCase();
    if (key.contains('token') ||
        key.contains('access') ||
        key == 'authorization' ||
        key == 'cookie') {
      continue;
    }

    safeHeaders[entry.key] = entry.value.toString();
  }

  return safeHeaders;
}

Object? _safeBody(Object? data) {
  if (data is FormData) {
    return {
      'fields': {
        for (final field in data.fields)
          field.key: _isSensitiveKey(field.key) ? '<redacted>' : field.value,
      },
      'files': data.files.map((file) => file.key).toList(growable: false),
    };
  }

  if (data is Map) {
    return {
      for (final entry in data.entries)
        entry.key: _isSensitiveKey(entry.key.toString())
            ? '<redacted>'
            : _safeBody(entry.value),
    };
  }

  if (data is List) {
    return data.map(_safeBody).toList(growable: false);
  }

  return data;
}

bool _isSensitiveKey(String key) {
  final normalizedKey = key.toLowerCase();
  return normalizedKey.contains('token') ||
      normalizedKey.contains('access') ||
      normalizedKey == 'authorization' ||
      normalizedKey == 'cookie' ||
      normalizedKey == 'password' ||
      normalizedKey == 'secret';
}

String _durationLabel(RequestOptions options) {
  final stopwatch = options.extra[_requestStopwatchKey];
  if (stopwatch is! Stopwatch) {
    return 'duration=-';
  }

  stopwatch.stop();
  return 'duration=${stopwatch.elapsedMilliseconds}ms';
}

int _responseBodySize(Object? data) {
  if (data == null) {
    return 0;
  }

  if (data is String) {
    return data.length;
  }

  if (data is List<int>) {
    return data.length;
  }

  return data.toString().length;
}

String _bodyPreview(Object? data, {bool preserveFormatting = false}) {
  if (data == null) {
    return '<empty>';
  }

  final normalized = preserveFormatting
      ? data.toString().trim()
      : data.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return '<empty>';
  }

  if (normalized.length <= _maxBodyPreviewLength) {
    return normalized;
  }

  return '${normalized.substring(0, _maxBodyPreviewLength)}...<truncated>';
}

String _formatBlock(Object? value) {
  if (value == null) {
    return '  <empty>';
  }

  final normalizedValue = _normalizeForJson(value);
  final formatted = const JsonEncoder.withIndent('  ').convert(normalizedValue);
  final preview = _bodyPreview(formatted, preserveFormatting: true);
  if (preview == '<empty>') {
    return '  <empty>';
  }

  return preview.split('\n').map((line) => '  $line').join('\n');
}

Object? _normalizeForJson(Object? value) {
  if (value == null || value is num || value is bool || value is List) {
    if (value is List) {
      return value.map(_normalizeForJson).toList(growable: false);
    }

    return value;
  }

  if (value is String) {
    final trimmedValue = value.trim();
    if (trimmedValue.startsWith('{') || trimmedValue.startsWith('[')) {
      try {
        return _normalizeForJson(jsonDecode(trimmedValue) as Object?);
      } on FormatException {
        return value;
      }
    }

    return value;
  }

  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _normalizeForJson(entry.value),
    };
  }

  return value.toString();
}
