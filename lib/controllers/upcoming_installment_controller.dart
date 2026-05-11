import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_lead_model.dart';
import '../models/upcoming_installment_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';

class UpcomingInstallmentController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = true.obs;
  var isDropdownLoading = true.obs;
  var installments = <StudentLead>[].obs;
  var summary = Rxn<UpcomingInstallmentSummary>();
  
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
    fetchInstallments();
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
        courses.assignAll((results[0] as List).map((e) => DropdownItem(
          id: e['Course_ID'] ?? e['Id'] ?? 0,
          name: e['Course_Name'] ?? e['Name'] ?? 'Course'
        )).toList());
      }

      // Batches
      if (results[1] is List && (results[1] as List).length > 3) {
        final batchData = (results[1] as List)[3];
        if (batchData is List) {
          batches.assignAll(batchData.map((e) => DropdownItem(
            id: e['Batch_ID'] ?? e['Id'] ?? 0,
            name: e['Batch_Name'] ?? e['Name'] ?? 'Batch'
          )).toList());
        }
      }

      // Students
      if (results[2] is List) {
        studentDropdown.assignAll((results[2] as List).map((e) => DropdownItem(
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

  Future<void> fetchInstallments({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      installments.clear();
    }

    // Set default date range if not set
    final now = DateTime.now();
    startDate.value ??= '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    endDate.value ??= '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    isLoading.value = true;
    try {
      final result = await _repository.getUpcomingInstallments(
        studentId: selectedStudentId.value ?? 0,
        batchId: selectedBatchId.value ?? 0,
        courseId: selectedCourseId.value ?? 0,
        startDate: startDate.value,
        endDate: endDate.value,
        page: currentPage.value,
      );

      if (result != null) {
        if (refresh) {
          installments.assignAll(result.installments);
        } else {
          installments.addAll(result.installments);
        }
        summary.value = result.summary;
        totalRecords.value = result.summary.totalRecords;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (!isLoading.value && installments.length < totalRecords.value) {
      currentPage.value++;
      fetchInstallments(refresh: false);
    }
  }
}
