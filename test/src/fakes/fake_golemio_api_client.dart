import 'package:mocktail/mocktail.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';

class MockGolemioApiClient extends Mock implements GolemioApiClient {}

MockGolemioApiClient mockGolemioApiClient({
  Object? response,
  Object? error,
}) {
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

Map<String, String?> verifySingleGetJson(
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

  return result.captured.single! as Map<String, String?>;
}
