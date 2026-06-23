import '../../../i18n/strings.g.dart';
import '../../core/errors/app_exception.dart';

String userMessageForAppError(
  Object? error, {
  required String fallbackMessage,
  String? invalidDataMessage,
}) {
  if (error is! AppException) {
    return fallbackMessage;
  }

  final strings = t;

  return switch (error.type) {
    AppExceptionType.missingToken => strings.errors.missingToken,
    AppExceptionType.unauthorized => strings.errors.unauthorized,
    AppExceptionType.network => strings.errors.network,
    AppExceptionType.timeout => strings.errors.timeout,
    AppExceptionType.emptyResponse => strings.errors.emptyResponse,
    AppExceptionType.invalidJson => strings.errors.invalidJson,
    AppExceptionType.invalidData =>
      invalidDataMessage ?? strings.errors.invalidData,
    AppExceptionType.badRequest => strings.errors.badRequest,
    AppExceptionType.notFound => strings.errors.notFound,
    AppExceptionType.server => strings.errors.server,
    AppExceptionType.unexpectedStatus => strings.errors.unexpectedStatus,
  };
}

String staleDataWarning(Object? error) {
  final message = userMessageForAppError(
    error,
    fallbackMessage: t.errors.refreshFailed,
  );

  return t.errors.stalePosition(message: message);
}
