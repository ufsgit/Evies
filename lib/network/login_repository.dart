import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class LoginRepository {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      debugPrint('--- API REQUEST ---');
      debugPrint('Endpoint: ${ApiEndpoints.login}');
      debugPrint('Payload: ${request.toJson()}');
      debugPrint('-------------------');

      // Note: We use the local network IP (192.168.86.3) instead of localhost.
      // This is because when running on a physical Android device or emulator,
      // 'localhost' resolves to the device itself, not the development PC.
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      debugPrint('--- API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('--------------------');

      if (response.statusCode == 200 && response.data != null) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        return LoginResponseModel(error: 'Failed to login. Please check credentials.', success: false);
      }
    } on DioException catch (e) {
      debugPrint('--- API ERROR ---');
      debugPrint('DioException Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('-----------------');

      String errorMessage = 'An unexpected error occurred';
      if (e.response != null && e.response?.data != null) {
         if (e.response?.data is Map && e.response?.data['message'] != null) {
           errorMessage = e.response?.data['message'];
         } else {
           errorMessage = e.message ?? errorMessage;
         }
      } else {
         errorMessage = e.message ?? errorMessage;
      }
      return LoginResponseModel(error: errorMessage, success: false);
    } catch (e) {
      debugPrint('Exception: $e');
      return LoginResponseModel(error: e.toString(), success: false);
    }
  }
}
