import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_lead_model.dart';
import '../models/student_report_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';

class StudentReportController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = true.obs;
  var isDropdownLoading = true.obs;
  var students = <StudentLead>[].obs;
  var totalRecords = 0.obs;
  var currentPage = 1.obs;

  // Filters
  var searchTerm = ''.obs;
  var selectedBatchId = Rxn<int>();
  var selectedCourseId = Rxn<int>();
  var startDate = Rxn<String>();
  var endDate = Rxn<String>();

  // Dropdowns
  var batches = <DropdownItem>[].obs;
  var courses = <DropdownItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdowns();
    fetchReports();
  }

  Future<void> fetchDropdowns() async {
    isDropdownLoading.value = true;
    try {
      debugPrint('Fetching dropdowns for Student Report...');
      final results = await Future.wait([
        _repository.fetchDropdown(ApiEndpoints.batchDropdown),
        _repository.fetchDropdown(ApiEndpoints.courseDropdown),
      ]);

      if (results[0] is List) {
        final batchList = results[0] as List;
        batches.assignAll(batchList.map((e) => DropdownItem(
          id: e['Batch_ID'] ?? e['Id'] ?? 0,
          name: e['Batch_Name'] ?? e['Name'] ?? 'Batch'
        )).toList());
      }

      if (results[1] is List) {
        final courseList = results[1] as List;
        courses.assignAll(courseList.map((e) => DropdownItem(
          id: e['Course_ID'] ?? e['Id'] ?? 0,
          name: e['Course_Name'] ?? e['Name'] ?? 'Course'
        )).toList());
      }
      debugPrint('Dropdowns fetched successfully');
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');
    } finally {
      isDropdownLoading.value = false;
    }
  }

  Future<void> fetchReports({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      students.clear();
    }

    isLoading.value = true;
    try {
      debugPrint('Fetching Student Reports - Page: ${currentPage.value}');
      final result = await _repository.getStudentReport(
        searchTerm: searchTerm.value,
        batchId: selectedBatchId.value,
        courseId: selectedCourseId.value,
        startDate: startDate.value,
        endDate: endDate.value,
        page: currentPage.value,
      );

      if (result != null) {
        if (refresh) {
          students.assignAll(result.students);
        } else {
          students.addAll(result.students);
        }
        totalRecords.value = result.totalRecords;
        debugPrint('Fetched ${result.students.length} students. Total: ${result.totalRecords}');
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchTerm.value = value;
    fetchReports();
  }

  void loadMore() {
    if (!isLoading.value && students.length < totalRecords.value) {
      currentPage.value++;
      fetchReports(refresh: false);
    }
  }
}
