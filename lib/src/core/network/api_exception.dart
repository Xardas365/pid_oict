import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.cause});

  factory ApiException.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;

    return ApiException(
      message: _messageFor(exception),
      statusCode: statusCode,
      cause: exception,
    );
  }

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' [$statusCode]';
    return 'ApiException$status: $message';
  }
}

String _messageFor(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout => 'Connection timed out.',
    DioExceptionType.sendTimeout => 'Request send timed out.',
    DioExceptionType.receiveTimeout => 'Response receive timed out.',
    DioExceptionType.badResponse => 'Unexpected API response.',
    DioExceptionType.cancel => 'Request was cancelled.',
    DioExceptionType.connectionError => 'Could not connect to the API.',
    DioExceptionType.badCertificate => 'Invalid API certificate.',
    DioExceptionType.unknown => 'Unexpected network error.',
  };
}
