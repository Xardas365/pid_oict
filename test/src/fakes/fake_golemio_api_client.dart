import 'package:mocktail/mocktail.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';
import 'package:pid_oict/src/core/network/golemio_query_parameters.dart';

class MockGolemioApiClient extends Mock implements GolemioApiClient {}

var _fallbackValuesRegistered = false;

MockGolemioApiClient mockGolemioApiClient({
  Object? response,
  Object? error,
}) {
  _registerFallbackValues();

  final client = MockGolemioApiClient();

  final stub = when(
    () => client.getJson(
      any(),
      queryParameters: any(named: 'queryParameters'),
      notFoundEmptyListAsSuccess: any(named: 'notFoundEmptyListAsSuccess'),
    ),
  );

  if (error != null) {
    stub.thenThrow(error);
  } else {
    stub.thenAnswer((_) async => response);
  }

  return client;
}

GolemioQueryParameters verifySingleGetJson(
  MockGolemioApiClient client,
  String path, {
  bool notFoundEmptyListAsSuccess = false,
}) {
  final result = verify(
    () => client.getJson(
      path,
      queryParameters: captureAny(named: 'queryParameters'),
      notFoundEmptyListAsSuccess: notFoundEmptyListAsSuccess,
    ),
  )..called(1);

  return result.captured.single! as GolemioQueryParameters;
}

void _registerFallbackValues() {
  if (_fallbackValuesRegistered) {
    return;
  }

  registerFallbackValue(const GolemioQueryParameters.empty());
  _fallbackValuesRegistered = true;
}
