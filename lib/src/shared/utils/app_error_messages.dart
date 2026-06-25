import '../../../i18n/strings.g.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/app_failure.dart';

String userMessageForAppError(
  Object? error, {
  required String fallbackMessage,
  String? invalidDataMessage,
}) {
  if (error == null) {
    return fallbackMessage;
  }

  final failure = switch (error) {
    final AppFailure failure => failure,
    final AppException exception => AppFailure.fromException(exception),
    _ => AppFailure.unknown(error),
  };
  final strings = t;

  return switch (failure.userMessageKey) {
    AppFailureMessageKey.missingToken => strings.errors.missingToken,
    AppFailureMessageKey.unauthorized => strings.errors.unauthorized,
    AppFailureMessageKey.network => strings.errors.network,
    AppFailureMessageKey.timeout => strings.errors.timeout,
    AppFailureMessageKey.emptyResponse => strings.errors.emptyResponse,
    AppFailureMessageKey.invalidJson => strings.errors.invalidJson,
    AppFailureMessageKey.invalidData =>
      invalidDataMessage ?? strings.errors.invalidData,
    AppFailureMessageKey.badRequest => strings.errors.badRequest,
    AppFailureMessageKey.notFound => strings.errors.notFound,
    AppFailureMessageKey.server => strings.errors.server,
    AppFailureMessageKey.unexpectedStatus => strings.errors.unexpectedStatus,
    AppFailureMessageKey.fallback => fallbackMessage,
  };
}

String staleDataWarning(Object? error) {
  final message = userMessageForAppError(
    error,
    fallbackMessage: t.errors.refreshFailed,
  );

  return t.errors.stalePosition(message: message);
}
