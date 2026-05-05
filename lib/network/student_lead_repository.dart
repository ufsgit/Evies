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

  Future<List<Map<String, dynamic>>> fetchDropdown(String endpoint) async {
    try {
      final response = await _apiClient.dio.get(endpoint);
      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map && response.data.containsKey('data')) {
           return List<Map<String, dynamic>>.from(response.data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Exception in fetchDropdown ($endpoint): $e');
      return [];
    }
  }

  Future<dynamic> getStudentDetails(int studentId) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.getStudentLeads}$studentId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getStudentDetails: $e');
      return null;
    }
  }


  Future<bool> saveStudent(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.saveStudent, data: data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception in saveStudent: $e');
      return false;
    }
  }
}

