import 'package:flutter/material.dart';
import '../models/student_lead_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class StudentLeadRepository {
  final ApiClient _apiClient = ApiClient();

  Future<StudentLeadResponseModel?> fetchStudentLeads({int page = 1}) async {
    try {
      final url = '${ApiEndpoints.getStudentLeads}?page=$page';
      debugPrint('--- STUDENT LEADS API REQUEST ---');
      debugPrint('Endpoint: $url');
      debugPrint('-------------------');
      
      final response = await _apiClient.dio.get(url);

      if (response.statusCode == 200) {
        debugPrint('--- STUDENT LEADS API RESPONSE ---');
        debugPrint(response.data.toString());
        return StudentLeadResponseModel.fromJson(response.data);
      } else {
        debugPrint('Error fetching student leads: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in fetchStudentLeads: $e');
      return null;
    }
  }
}
