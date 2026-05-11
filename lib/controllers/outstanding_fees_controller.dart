import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_lead_model.dart';
import '../models/outstanding_fees_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';

class OutstandingFeesController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = true.obs;
  var isDropdownLoading = true.obs;
  var students = <StudentLead>[].obs;
  var summary = Rxn<OutstandingFeesSummary>();
  
  var totalRecords = 0.obs;
  var currentPage = 1.obs;

  // Filters
  var selectedBatchId = Rxn<int>();
  var selectedCourseId = Rxn<int>();
  var selectedStudentId = Rxn<int>();
  var startDate = Rxn<String>();
  var endDate = Rxn<String>();

  // Dropdowns
  var batches = <DropdownItem>[].obs;
  var courses = <DropdownItem>[].obs;
  var studentDropdown = <DropdownItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdowns();
    fetchFees();
  }

  Future<void> fetchDropdowns() async {
    isDropdownLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.fetchDropdown(ApiEndpoints.courseDropdown),
        _repository.fetchDropdown(ApiEndpoints.batchDropdown),
        _repository.fetchDropdown(ApiEndpoints.allStudentsDropdown),
      ]);

      // Courses
      if (results[0] is List) {
        final courseList = results[0] as List;
        courses.assignAll(courseList.map((e) => DropdownItem(
          id: e['Course_ID'] ?? e['Id'] ?? 0,
          name: e['Course_Name'] ?? e['Name'] ?? 'Course'
        )).toList());
      }

      // Batches - Technical docs state Batch info is in index 3 of the response array
      if (results[1] is List && results[1].length > 3) {
        final batchData = results[1][3];
        if (batchData is List) {
          final batchList = batchData as List;
          batches.assignAll(batchList.map((e) => DropdownItem(
            id: e['Batch_ID'] ?? e['Id'] ?? 0,
            name: e['Batch_Name'] ?? e['Name'] ?? 'Batch'
          )).toList());
        }
      }

      // Students
      if (results[2] is List) {
        final studentList = results[2] as List;
        studentDropdown.assignAll(studentList.map((e) => DropdownItem(
          id: e['Student_ID'] ?? e['Id'] ?? 0,
          name: e['First_Name'] ?? e['Name'] ?? 'Student'
        )).toList());
      }
    } catch (e) {
      debugPrint('Error in fetchDropdowns: $e');
    } finally {
      isDropdownLoading.value = false;
    }
  }

  Future<void> fetchFees({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      students.clear();
    }

    // Set default date range if not set (from 1st of month to today)
    final now = DateTime.now();
    startDate.value ??= '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    endDate.value ??= '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    isLoading.value = true;
    try {
      final result = await _repository.getOutstandingFees(
        studentId: selectedStudentId.value ?? 0,
        batchId: selectedBatchId.value ?? 0,
        courseId: selectedCourseId.value ?? 0,
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
        summary.value = result.summary;
        totalRecords.value = result.summary.totalRecords;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (!isLoading.value && students.length < totalRecords.value) {
      currentPage.value++;
      fetchFees(refresh: false);
    }
  }
}
