import 'package:dio/dio.dart';
import 'package:pid_oict/src/core/logging/golemio_debug_logger.dart';
import 'package:pid_oict/src/core/network/logging_interceptor.dart';

import '../config/app_config.dart';

Dio createGolemioDio({
  String baseUrl = golemioBaseUrl,
  Duration timeout = const Duration(seconds: 20),
  bool enableLogging = isGolemioDebugLoggingEnabled,
  void Function(String message)? logger,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      responseType: ResponseType.plain,
    ),
  );

  if (enableLogging) {
    dio.interceptors.add(DebugLoggingInterceptor(logger: logger));
  }

  return dio;
}
