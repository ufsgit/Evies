import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/work_report_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';

class WorkReportController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = false.obs;
  var isDetailsLoading = false.obs;
  var summaryList = <WorkReportSummary>[].obs;
  var detailsList = <WorkReportDetail>[].obs;

  // Filters
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var useCreatedDate = 1.obs; // 1 for Created Date, 0 for Next Follow-up

  // Dropdowns
  var departments = <DropdownItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    fromDate.value = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    toDate.value = fromDate.value;
    fetchSummary();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      final data = await _repository.fetchDropdown(ApiEndpoints.departmentDropdown);
      if (data is List) {
        departments.assignAll(data.map((e) => DropdownItem(
          id: e['Id'] ?? e['Department_Id'] ?? 0,
          name: e['Name'] ?? e['Department_Name'] ?? 'Dept'
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching departments: $e');
    }
  }

  Future<void> fetchSummary() async {
    isLoading.value = true;
    try {
      final results = await _repository.getWorkReportSummary(
        fromDate: fromDate.value,
        toDate: toDate.value,
        useCreatedDate: useCreatedDate.value,
      );
      summaryList.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDetails(int staffId) async {
    isDetailsLoading.value = true;
    detailsList.clear();
    try {
      final results = await _repository.getWorkReportDetails(
        staffId: staffId,
        fromDate: fromDate.value,
        toDate: toDate.value,
        useCreatedDate: useCreatedDate.value,
      );
      detailsList.assignAll(results);
    } finally {
      isDetailsLoading.value = false;
    }
  }

  void toggleDateFilter() {
    useCreatedDate.value = useCreatedDate.value == 1 ? 0 : 1;
    fetchSummary();
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      if (isFrom) {
        fromDate.value = formattedDate;
      } else {
        toDate.value = formattedDate;
      }
      fetchSummary();
    }
  }
}
