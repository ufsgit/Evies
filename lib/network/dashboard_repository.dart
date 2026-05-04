import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardResponseModel?> getDashboardData() async {
    try {
      debugPrint('--- API REQUEST ---');
      debugPrint('Endpoint: ${ApiEndpoints.dashboard}');
      debugPrint('-------------------');

      final response = await _apiClient.dio.get(ApiEndpoints.dashboard);

      debugPrint('--- API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('--------------------');

      if (response.statusCode == 200 && response.data is List) {
        return DashboardResponseModel.fromJson(response.data as List);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('--- API ERROR ---');
      debugPrint('DioException Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('-----------------');
      return null;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }
}
