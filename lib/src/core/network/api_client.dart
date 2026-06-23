import 'package:dio/dio.dart';
import 'package:pid_oict/src/core/network/api_exception.dart';
import 'package:pid_oict/src/core/network/dio_provider.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? createDio();

  final Dio _dio;

  Future<T> get<T>(
    String pathOrUrl, {
    required T Function(Object? json) parser,
  }) async {
    try {
      final response = await _get(pathOrUrl);
      return parser(response.data);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Response<Object?>> _get(String pathOrUrl) {
    final uri = Uri.parse(pathOrUrl);

    if (uri.hasScheme) {
      return _dio.getUri<Object?>(uri);
    }

    return _dio.get<Object?>(pathOrUrl);
  }
}
