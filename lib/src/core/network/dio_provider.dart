import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pid_oict/src/core/network/logging_interceptor.dart';

const apiBaseUrl = 'https://api.golemio.cz';

Dio createDio({bool enableLogging = kDebugMode}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // Keep this explicit because the API client contract requires JSON.
      // ignore: avoid_redundant_argument_values
      responseType: ResponseType.json,
    ),
  );

  if (enableLogging) {
    dio.interceptors.add(DebugLoggingInterceptor());
  }

  return dio;
}
