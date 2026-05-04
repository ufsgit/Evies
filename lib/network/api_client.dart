import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); 
      },
      onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); 
      },
      onError: (DioException e, handler) {
        // Do something with response error
        return handler.next(e); 
      },
    ));
  }

  Dio get dio => _dio;
}
