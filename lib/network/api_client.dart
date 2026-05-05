import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fetch token from SharedPreferences and attach it to headers
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
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
