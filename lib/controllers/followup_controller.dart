import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_lead_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';
import 'package:intl/intl.dart';

class FollowupController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();
  
  final StudentLead lead;
  
  FollowupController({required this.lead});

  var isLoading = false.obs;
  var isDropdownLoading = true.obs;

  // Form Fields
  var selectedBranchId = RxnInt();
  var selectedDepartmentId = RxnInt();
  var selectedStaffId = RxnInt();
  var selectedStatusId = RxnInt();
  var selectedDate = Rxn<DateTime>();
  var selectedTemplateId = RxnInt();
  final remarkController = TextEditingController();

  // Dropdown Data
  var branches = <DropdownItem>[].obs;
  var departments = <DropdownItem>[].obs;
  var staff = <DropdownItem>[].obs;
  var statuses = <DropdownItem>[].obs;
  var templates = <DropdownItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with lead data
    selectedBranchId.value = lead.branchId;
    selectedStaffId.value = lead.assignedStaffId;
    selectedStatusId.value = lead.statusId;
    if (lead.followUpDate != null) {
      try {
        selectedDate.value = DateTime.parse(lead.followUpDate!);
      } catch (_) {}
    }
    
    fetchDropdowns();
  }

  Future<void> fetchDropdowns() async {
    isDropdownLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.fetchDropdown(ApiEndpoints.branchDropdown),
        _repository.fetchDropdown(ApiEndpoints.departmentDropdown),
        _repository.fetchDropdown(ApiEndpoints.userDropdown),
        _repository.fetchDropdown(ApiEndpoints.getFollowupStatus),
      ]);

      branches.assignAll(_makeUnique(results[0].map((e) => DropdownItem.fromJson(e, idKey: 'Branch_ID', nameKey: 'Branch_Name')).toList()));
      departments.assignAll(_makeUnique(results[1].map((e) => DropdownItem.fromJson(e, idKey: 'Department_Id', nameKey: 'Department_Name')).toList()));
      
      // Robust Staff Mapping
      staff.assignAll(_makeUnique(results[2].map((e) {
        String name = (e['User_Name'] ?? e['First_Name'] ?? e['FirstName'] ?? e['To_User_Name'] ?? 'Staff Member').toString();
        return DropdownItem(id: e['User_ID'] ?? e['User_Id'] ?? 0, name: name);
      }).toList()));

      // Robust Status Mapping
      statuses.assignAll(_makeUnique(results[3].map((e) {
        String name = (e['Status_Name'] ?? e['Follow_Up_Status_Name'] ?? e['name'] ?? 'Status').toString();
        return DropdownItem(id: e['Status_Id'] ?? e['Status_ID'] ?? e['Follow_Up_Status_ID'] ?? 0, name: name);
      }).toList()));
      
      // Mock templates for now as per image
      templates.assignAll([
        DropdownItem(id: 1, name: 'Follow-up Email'),
        DropdownItem(id: 2, name: 'Registration Link'),
      ]);

    } catch (e) {
      Get.snackbar('Error', 'Failed to load dropdowns');
    } finally {
      isDropdownLoading.value = false;
    }
  }

  List<DropdownItem> _makeUnique(List<DropdownItem> items) {
    final ids = <int>{};
    return items.where((item) => ids.add(item.id)).toList();
  }

  Future<void> saveFollowup() async {
    if (selectedStatusId.value == null) {
      Get.snackbar('Error', 'Please select a status');
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        'Student_ID': lead.studentId,
        'Branch_ID': selectedBranchId.value,
        'Department_ID': selectedDepartmentId.value,
        'Assigned_Staff_ID': selectedStaffId.value,
        'Follow_Up_Status_ID': selectedStatusId.value,
        'Next_Follow_Up_Date': selectedDate.value != null 
            ? DateFormat('yyyy-MM-dd').format(selectedDate.value!) 
            : null,
        'Remark': remarkController.text,
        'Email_Template_ID': selectedTemplateId.value,
      };

      final success = await _repository.saveFollowup(data);
      if (success) {
        Get.back(result: true);
        Get.snackbar('Success', 'Follow-up saved successfully');
      } else {
        Get.snackbar('Error', 'Failed to save follow-up');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}
