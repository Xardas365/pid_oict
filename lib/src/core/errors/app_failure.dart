import 'app_exception.dart';

enum AppFailureCategory {
  configuration,
  authentication,
  request,
  notFound,
  timeout,
  network,
  emptyResponse,
  parsing,
  invalidData,
  server,
  unexpectedStatus,
  unknown,
}

enum AppFailureMessageKey {
  missingToken,
  unauthorized,
  network,
  timeout,
  emptyResponse,
  invalidJson,
  invalidData,
  badRequest,
  notFound,
  server,
  unexpectedStatus,
  fallback,
}

class AppFailure {
  const AppFailure({
    required this.category,
    required this.userMessageKey,
    required this.debugMessage,
    required this.retryable,
    this.statusCode,
  });

  factory AppFailure.fromException(AppException exception) {
    return switch (exception.type) {
      AppExceptionType.missingToken => AppFailure(
        category: AppFailureCategory.configuration,
        userMessageKey: AppFailureMessageKey.missingToken,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.unauthorized => AppFailure(
        category: AppFailureCategory.authentication,
        userMessageKey: AppFailureMessageKey.unauthorized,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.badRequest => AppFailure(
        category: AppFailureCategory.request,
        userMessageKey: AppFailureMessageKey.badRequest,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.notFound => AppFailure(
        category: AppFailureCategory.notFound,
        userMessageKey: AppFailureMessageKey.notFound,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.timeout => AppFailure(
        category: AppFailureCategory.timeout,
        userMessageKey: AppFailureMessageKey.timeout,
        debugMessage: exception.message,
        retryable: true,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.network => AppFailure(
        category: AppFailureCategory.network,
        userMessageKey: AppFailureMessageKey.network,
        debugMessage: exception.message,
        retryable: true,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.emptyResponse => AppFailure(
        category: AppFailureCategory.emptyResponse,
        userMessageKey: AppFailureMessageKey.emptyResponse,
        debugMessage: exception.message,
        retryable: true,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.invalidJson => AppFailure(
        category: AppFailureCategory.parsing,
        userMessageKey: AppFailureMessageKey.invalidJson,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.invalidData => AppFailure(
        category: AppFailureCategory.invalidData,
        userMessageKey: AppFailureMessageKey.invalidData,
        debugMessage: exception.message,
        retryable: false,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.server => AppFailure(
        category: AppFailureCategory.server,
        userMessageKey: AppFailureMessageKey.server,
        debugMessage: exception.message,
        retryable: true,
        statusCode: exception.statusCode,
      ),
      AppExceptionType.unexpectedStatus => AppFailure(
        category: AppFailureCategory.unexpectedStatus,
        userMessageKey: AppFailureMessageKey.unexpectedStatus,
        debugMessage: exception.message,
        retryable: true,
        statusCode: exception.statusCode,
      ),
    };
  }

  factory AppFailure.unknown(Object error) {
    return AppFailure(
      category: AppFailureCategory.unknown,
      userMessageKey: AppFailureMessageKey.fallback,
      debugMessage: error.toString(),
      retryable: true,
    );
  }

  factory AppFailure.fromObject(Object error) {
    return switch (error) {
      final AppFailure failure => failure,
      final AppException exception => AppFailure.fromException(exception),
      _ => AppFailure.unknown(error),
    };
  }

  final AppFailureCategory category;
  final AppFailureMessageKey userMessageKey;
  final String debugMessage;
  final bool retryable;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ', statusCode: $statusCode';

    return 'AppFailure(category: $category$status, '
        'retryable: $retryable, debugMessage: $debugMessage)';
  }
}
