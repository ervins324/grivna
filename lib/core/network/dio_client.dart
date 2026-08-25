import 'package:dio/dio.dart';

class DioClient {
  static Dio createDio({String? baseUrl, Map<String, dynamic>? headers}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: headers ??
            {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );

    return dio;
  }
}
