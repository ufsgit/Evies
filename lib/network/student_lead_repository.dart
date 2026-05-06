import 'package:flutter/foundation.dart';
import '../models/student_lead_model.dart';
import '../models/dropdown_models.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class StudentLeadRepository {
  final ApiClient _apiClient = ApiClient();

  Future<StudentLeadResponseModel?> fetchStudentLeads({
    int page = 1,
    String searchTerm = '',
    int? staffId,
    int? branchId,
    String? status,
  }) async {
    try {
      String url = '${ApiEndpoints.getStudentLeads}?page=$page&pageSize=20';
      if (searchTerm.isNotEmpty) url += '&student_Name=$searchTerm';
      if (staffId != null) url += '&assignedStaffId=$staffId';
      if (branchId != null) url += '&branchId=$branchId';
      if (status != null && status != 'all') url += '&activeStatus=$status';
      url += '&enrollment_status=all'; 

      debugPrint('--- STUDENT LEADS API REQUEST ---');
      debugPrint('Endpoint: $url');
      debugPrint('-------------------');
      
      final response = await _apiClient.dio.get(url);

      if (response.statusCode == 200) {
        debugPrint('--- STUDENT LEADS API RESPONSE ---');
        debugPrint(response.data.toString());
        debugPrint('-------------------');
        return StudentLeadResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Exception in fetchStudentLeads: $e');
      return null;
    }
  }

  Future<List<BranchModel>> fetchBranches() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.branchDropdown);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => BranchModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<StaffModel>> fetchStaff() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.userDropdown);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => StaffModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<FollowupStatusModel>> fetchFollowupStatuses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.getFollowupStatus);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => FollowupStatusModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDropdown(String endpoint) async {
    try {
      final response = await _apiClient.dio.get(endpoint);
      if (response.statusCode == 200) {
        dynamic data = response.data;
        
        // Handle nested list responses (common in this backend)
        if (data is List) {
          if (data.isNotEmpty && data[0] is List) {
            for (var item in data) {
              if (item is List && item.isNotEmpty && item[0] is Map) {
                return List<Map<String, dynamic>>.from(item);
              }
            }
          }
          return data.whereType<Map<String, dynamic>>().toList();
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data']);
          }
          // If it's a single map, wrap it in a list
          return [data.cast<String, dynamic>()];
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

  Future<bool> saveFollowup(Map<String, dynamic> data) async {
    try {
      debugPrint('--- SAVE FOLLOWUP REQUEST ---');
      debugPrint('Data: $data');
      
      final response = await _apiClient.dio.post(ApiEndpoints.saveStudentFollowup, data: data);
      
      debugPrint('--- SAVE FOLLOWUP RESPONSE ---');
      debugPrint(response.data.toString());
      debugPrint('-------------------');
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Exception in saveFollowup: $e');
      return false;
    }
  }
}

