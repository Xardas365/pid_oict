import 'package:flutter_test/flutter_test.dart';
import 'package:pid_oict/src/core/errors/app_exception.dart';
import 'package:pid_oict/src/core/errors/app_failure.dart';

void main() {
  group('AppFailure', () {
    test('maps 401 unauthorized exception to authentication failure', () {
      const exception = AppException(
        type: AppExceptionType.unauthorized,
        message: 'Unauthorized.',
        statusCode: 401,
      );

      final failure = AppFailure.fromException(exception);

      expect(failure.category, AppFailureCategory.authentication);
      expect(failure.userMessageKey, AppFailureMessageKey.unauthorized);
      expect(failure.retryable, isFalse);
      expect(failure.statusCode, 401);
      expect(failure.debugMessage, 'Unauthorized.');
    });

    test('maps 403 unauthorized exception to authentication failure', () {
      const exception = AppException(
        type: AppExceptionType.unauthorized,
        message: 'Forbidden.',
        statusCode: 403,
      );

      final failure = AppFailure.fromException(exception);

      expect(failure.category, AppFailureCategory.authentication);
      expect(failure.userMessageKey, AppFailureMessageKey.unauthorized);
      expect(failure.retryable, isFalse);
      expect(failure.statusCode, 403);
    });

    test('maps timeout and network failures as retryable', () {
      final timeout = AppFailure.fromException(
        const AppException(
          type: AppExceptionType.timeout,
          message: 'Timeout.',
        ),
      );
      final network = AppFailure.fromException(
        const AppException(
          type: AppExceptionType.network,
          message: 'Network.',
        ),
      );

      expect(timeout.category, AppFailureCategory.timeout);
      expect(timeout.retryable, isTrue);
      expect(network.category, AppFailureCategory.network);
      expect(network.retryable, isTrue);
    });

    test('maps JSON parse errors as non-crashing parsing failures', () {
      final failure = AppFailure.fromException(
        const AppException(
          type: AppExceptionType.invalidJson,
          message: 'Invalid JSON.',
        ),
      );

      expect(failure.category, AppFailureCategory.parsing);
      expect(failure.userMessageKey, AppFailureMessageKey.invalidJson);
      expect(failure.retryable, isFalse);
    });

    test('maps unknown errors to generic fallback failure', () {
      final failure = AppFailure.fromObject(StateError('Unexpected state.'));

      expect(failure.category, AppFailureCategory.unknown);
      expect(failure.userMessageKey, AppFailureMessageKey.fallback);
      expect(failure.retryable, isTrue);
      expect(failure.debugMessage, contains('Unexpected state.'));
    });
  });
}
