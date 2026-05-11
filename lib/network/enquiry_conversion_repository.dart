import 'package:dio/dio.dart';
import '../models/enquiry_conversion_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class EnquiryConversionRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<EnquiryConversionSummary>> fetchSummary(String? fromDate, String? toDate) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (fromDate != null && fromDate.isNotEmpty) queryParams['fromDate'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) queryParams['toDate'] = toDate;

      final response = await _apiClient.dio.get(
        ApiEndpoints.getEnquiryConversionSummary,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        
        // Handle array of arrays wrapper
        if (data is List && data.isNotEmpty && data.first is List) {
          data = data.first;
        }

        print('RAW SUMMARY DATA: $data');

        if (data is List) {
          return data.map((json) => EnquiryConversionSummary.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch summary: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch summary: $e');
    }
  }

  Future<List<EnquiryConversionDetail>> fetchDetails(int sourceId, String? fromDate, String? toDate) async {
    try {
      final Map<String, dynamic> queryParams = {'sourceId': sourceId};
      if (fromDate != null && fromDate.isNotEmpty) queryParams['fromDate'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) queryParams['toDate'] = toDate;

      final response = await _apiClient.dio.get(
        ApiEndpoints.getEnquiryConversionDetails,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        
        // Handle array of arrays wrapper
        if (data is List && data.isNotEmpty && data.first is List) {
          data = data.first;
        }

        if (data is List) {
          return data.map((json) => EnquiryConversionDetail.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch details: $e');
    }
  }
}
