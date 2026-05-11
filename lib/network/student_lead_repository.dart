import 'package:flutter/foundation.dart';
import '../models/student_lead_model.dart';
import '../models/dropdown_models.dart';
import '../models/enquiry_summary_model.dart';
import '../models/student_report_model.dart';
import '../models/outstanding_fees_model.dart';
import '../models/upcoming_installment_model.dart';
import '../models/work_report_model.dart';
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

  Future<EnquirySummaryResponse?> getEnquirySummary({String? fromDate, String? toDate}) async {
    try {
      String url = ApiEndpoints.getEnquirySummary;
      if (fromDate != null && toDate != null) {
        url += '?fromDate=$fromDate&toDate=$toDate';
      }
      debugPrint('--- ENQUIRY SUMMARY API REQUEST ---');
      debugPrint('Endpoint: $url');
      debugPrint('-------------------');
      
      final response = await _apiClient.dio.get(url);

      if (response.statusCode == 200) {
        debugPrint('--- ENQUIRY SUMMARY API RESPONSE ---');
        debugPrint(response.data.toString());
        debugPrint('-------------------');
        
        if (response.data is List) {
          return EnquirySummaryResponse.fromJson(response.data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getEnquirySummary: $e');
      return null;
    }
  }

  Future<StudentReportResponseModel?> getStudentReport({
    String? searchTerm,
    int? batchId,
    int? courseId,
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      String url = '${ApiEndpoints.getStudentReport}?PageNumber=$page&PageSize=12';
      if (searchTerm != null && searchTerm.isNotEmpty) url += '&Student_Search=$searchTerm';
      if (batchId != null) url += '&Batch_Search=$batchId';
      if (courseId != null) url += '&Course_Search=$courseId';
      if (startDate != null) url += '&Start_Date=$startDate';
      if (endDate != null) url += '&End_Date=$endDate';

      debugPrint('--- STUDENT REPORT API REQUEST ---');
      debugPrint('Endpoint: $url');
      
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return StudentReportResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getStudentReport: $e');
      return null;
    }
  }

  Future<OutstandingFeesResponseModel?> getOutstandingFees({
    int studentId = 0,
    int batchId = 0,
    int courseId = 0,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      // Ensure dates are sent as required by backend
      final start = startDate ?? '';
      final end = endDate ?? '';
      
      String url = '${ApiEndpoints.getOutstandingFees}?Student_ID=$studentId&Batch_ID=$batchId&Course_ID=$courseId&PageNumber=$page&PageSize=$pageSize&Start_Date=$start&End_Date=$end';

      debugPrint('--- OUTSTANDING FEES API REQUEST ---');
      debugPrint('Endpoint: $url');

      final response = await _apiClient.dio.get(url);
      debugPrint('--- OUTSTANDING FEES API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('-------------------------------------');
      
      if (response.statusCode == 200 && response.data is List) {
        return OutstandingFeesResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getOutstandingFees: $e');
      return null;
    }
  }

  Future<UpcomingInstallmentResponseModel?> getUpcomingInstallments({
    int studentId = 0,
    int batchId = 0,
    int courseId = 0,
    String? startDate,
    String? endDate,
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      final start = startDate ?? '';
      final end = endDate ?? '';
      
      String url = '${ApiEndpoints.getUpcomingInstallments}?Student_ID=$studentId&Batch_ID=$batchId&Course_ID=$courseId&PageNumber=$page&PageSize=$pageSize&Start_Date=$start&End_Date=$end';

      debugPrint('--- UPCOMING INSTALLMENTS API REQUEST ---');
      debugPrint('Endpoint: $url');

      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return UpcomingInstallmentResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Exception in getUpcomingInstallments: $e');
      return null;
    }
  }

  Future<List<WorkReportSummary>> getWorkReportSummary({
    required String fromDate,
    required String toDate,
    int useCreatedDate = 1,
  }) async {
    try {
      String url = '${ApiEndpoints.getWorkReportSummary}?fromDate=$fromDate&toDate=$toDate&useCreatedDate=$useCreatedDate';
      debugPrint('--- WORK REPORT SUMMARY REQUEST ---');
      debugPrint('Endpoint: $url');
      
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => WorkReportSummary.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getWorkReportSummary: $e');
      return [];
    }
  }

  Future<List<WorkReportDetail>> getWorkReportDetails({
    required int staffId,
    required String fromDate,
    required String toDate,
    int useCreatedDate = 1,
    int? departmentId,
    String? searchBy,
    String? searchTerm,
  }) async {
    try {
      String url = '${ApiEndpoints.getWorkReportDetails}?staffId=$staffId&fromDate=$fromDate&toDate=$toDate&useCreatedDate=$useCreatedDate';
      if (departmentId != null) url += '&departmentId=$departmentId';
      if (searchBy != null) url += '&searchBy=$searchBy';
      if (searchTerm != null) url += '&searchTerm=$searchTerm';

      debugPrint('--- WORK REPORT DETAILS REQUEST ---');
      debugPrint('Endpoint: $url');
      
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => WorkReportDetail.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getWorkReportDetails: $e');
      return [];
    }
  }
}

