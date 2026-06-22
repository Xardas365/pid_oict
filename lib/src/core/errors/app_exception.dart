enum AppExceptionType {
  missingToken,
  unauthorized,
  badRequest,
  notFound,
  timeout,
  network,
  emptyResponse,
  invalidJson,
  server,
  unexpectedStatus,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final AppExceptionType type;
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ', statusCode: $statusCode';

    return 'AppException(type: $type$status, message: $message)';
  }
}
