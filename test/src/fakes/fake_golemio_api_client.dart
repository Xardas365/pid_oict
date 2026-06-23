import 'package:pid_oict/src/core/config/app_config.dart';
import 'package:pid_oict/src/core/network/golemio_api_client.dart';

class GolemioApiClientCall {
  const GolemioApiClientCall({
    required this.path,
    required this.queryParameters,
    required this.notFoundEmptyListAsSuccess,
  });

  final String path;
  final Map<String, String?> queryParameters;
  final bool notFoundEmptyListAsSuccess;
}

class FakeGolemioApiClient implements GolemioApiClient {
  FakeGolemioApiClient({required this.response, this.error});

  final Object? response;
  final Object? error;
  final calls = <GolemioApiClientCall>[];

  @override
  AppConfig get config => const AppConfig(apiToken: 'test-token');

  @override
  Duration get timeout => const Duration(seconds: 1);

  @override
  Future<Object?> getJson(
    String path, {
    Map<String, String?> queryParameters = const {},
    bool notFoundEmptyListAsSuccess = false,
  }) async {
    calls.add(
      GolemioApiClientCall(
        path: path,
        queryParameters: Map<String, String?>.from(queryParameters),
        notFoundEmptyListAsSuccess: notFoundEmptyListAsSuccess,
      ),
    );

    final error = this.error;
    if (error != null) {
      throw error;
    }

    return response;
  }

  @override
  void close() {}
}
