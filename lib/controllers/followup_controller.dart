import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/student_lead_model.dart';
import '../models/enquiry_form_model.dart';
import '../network/student_lead_repository.dart';
import '../network/api_endpoints.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowupController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();
  
  final StudentLead lead;
  
  FollowupController({required this.lead});

  var isLoading = false.obs;
  var isDropdownLoading = true.obs;
  
  var loggedUserId = RxnInt();
  var loggedUserName = Rxn<String>();

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
    _loadLoggedUser();
    // Initialize with lead data
    selectedBranchId.value = lead.branchId;
    selectedDepartmentId.value = lead.departmentId;
    selectedStaffId.value = lead.assignedStaffId;
    selectedStatusId.value = lead.statusId;
    if (lead.followUpDate != null) {
      try {
        selectedDate.value = DateTime.parse(lead.followUpDate!);
      } catch (_) {}
    }
    
    fetchDropdowns();
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      // Trying the followup details endpoint instead of the 404 search-by-id endpoint
      final response = await _repository.fetchDropdown('${ApiEndpoints.getStudentCurrentFollowup}?student_Id=${lead.studentId}');
      if (response.isNotEmpty) {
        final data = response[0];
        if (data is Map) {
          if (selectedBranchId.value == null || selectedBranchId.value == 0) {
            selectedBranchId.value = int.tryParse(data['Branch_Id']?.toString() ?? data['Branch_ID']?.toString() ?? data['Branch_Id_']?.toString() ?? '0');
          }
          if (selectedDepartmentId.value == null || selectedDepartmentId.value == 0) {
            selectedDepartmentId.value = int.tryParse(data['Department_Id']?.toString() ?? data['Department_ID']?.toString() ?? data['Dept_Id']?.toString() ?? data['Department_Id_']?.toString() ?? '0');
          }
          
          // Staff Id
          if (selectedStaffId.value == null || selectedStaffId.value == 0 || selectedStaffId.value == loggedUserId.value) {
            var staffId = int.tryParse(data['Assigned_Staff_ID']?.toString() ?? data['User_Id']?.toString() ?? data['To_User_Id']?.toString() ?? '0');
            if (staffId != null && staffId > 0) selectedStaffId.value = staffId;
          }

          // Status Id
          var statusId = int.tryParse(data['Follow_Up_Status_Id']?.toString() ?? data['Follow_Up_Status_ID']?.toString() ?? data['Status_Id']?.toString() ?? data['Status_ID']?.toString() ?? '0');
          print('DEBUG: Fetched Status ID from API = $statusId');
          if (statusId != null && statusId > 0) {
            selectedStatusId.value = statusId;
          }

          // Followup Date
          if (selectedDate.value == null) {
            var dateStr = data['Next_Follow_Up_Date']?.toString() ?? data['FollowUp_Date']?.toString();
            if (dateStr != null && dateStr.isNotEmpty) {
              try {
                selectedDate.value = DateTime.parse(dateStr);
              } catch (_) {}
            }
          }

          // Remark
          if (remarkController.text.isEmpty) {
             remarkController.text = data['Remark']?.toString() ?? data['Followup_Remark']?.toString() ?? '';
          }
        }
      }
      
      // Final safety: if still null but we have departments, try to match
      _syncDepartmentByName();
    } catch (e) {
      debugPrint('Error fetching full details: $e');
    }
  }

  Future<void> _loadLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    loggedUserId.value = prefs.getInt('user_id');
    loggedUserName.value = prefs.getString('user_name');
    
    // Set default staff to logged user if no staff is assigned or it's a new follow-up
    if (selectedStaffId.value == null || selectedStaffId.value == 0) {
      selectedStaffId.value = loggedUserId.value;
    }
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
      
      // Explicit mapping for Department based on user provided JSON
      departments.assignAll(_makeUnique(results[1].map((e) {
        return DropdownItem(
          id: int.tryParse(e['Department_Id']?.toString() ?? e['Department_ID']?.toString() ?? e['Dept_ID']?.toString() ?? '0') ?? 0,
          name: (e['Department_Name'] ?? e['DepartmentName'] ?? e['name'] ?? 'Admission').toString(),
        );
      }).toList()));

      _syncDepartmentByName();
      
      // Robust Staff Mapping
      staff.assignAll(_makeUnique(results[2].map((e) {
        String name = (e['User_Name'] ?? e['First_Name'] ?? e['FirstName'] ?? e['To_User_Name'] ?? 'Staff Member').toString();
        return DropdownItem(id: e['User_ID'] ?? e['User_Id'] ?? 0, name: name);
      }).toList()));

      // Robust Status Mapping
      statuses.assignAll(_makeUnique(results[3].map((e) {
        String name = (e['Status_Name'] ?? e['Follow_Up_Status_Name'] ?? e['name'] ?? 'Status').toString();
        int id = int.tryParse(e['Status_Id']?.toString() ?? e['Status_ID']?.toString() ?? e['Follow_Up_Status_ID']?.toString() ?? '0') ?? 0;
        return DropdownItem(id: id, name: name);
      }).toList()));

      print('DEBUG: Extracted Dropdown Status IDs: ${statuses.map((e) => "${e.name}=${e.id}").toList()}');
      print('DEBUG: Current selectedStatusId.value = ${selectedStatusId.value}');
      
      // Mock templates for now as per image
      templates.assignAll([
        DropdownItem(id: 1, name: 'Follow-up Email'),
        DropdownItem(id: 2, name: 'Registration Link'),
      ]);

      _syncStatusByName();

    } catch (e) {
      Get.snackbar('Error', 'Failed to load dropdowns');
    } finally {
      isDropdownLoading.value = false;
    }
  }

  void _syncStatusByName() {
    if (statuses.isNotEmpty && (selectedStatusId.value == null || selectedStatusId.value == 0)) {
      String targetName = lead.statusName.trim().toLowerCase();
      if (targetName.isNotEmpty && targetName != 'unknown') {
        final match = statuses.firstWhereOrNull((e) => e.name.trim().toLowerCase() == targetName);
        if (match != null) {
          selectedStatusId.value = match.id;
          print('DEBUG: Matched Status ID by Name: ${match.name} -> ${match.id}');
        }
      }
    }
  }

  void _syncDepartmentByName() {
    if (departments.isNotEmpty && (selectedDepartmentId.value == null || selectedDepartmentId.value == 0)) {
      // If there's only one department, or one named Admission, auto-select it
      if (departments.length == 1) {
        selectedDepartmentId.value = departments[0].id;
      } else {
        final match = departments.firstWhereOrNull((e) => e.name.toLowerCase().contains('admission'));
        if (match != null) {
          selectedDepartmentId.value = match.id;
        }
      }
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

  String getSelectedBranchName() {
    if (branches.isEmpty) return (lead.branchName != null && lead.branchName.isNotEmpty) ? lead.branchName : '-';
    return branches.firstWhere(
      (e) => e.id == (selectedBranchId.value ?? 0), 
      orElse: () => DropdownItem(id: 0, name: (lead.branchName != null && lead.branchName.isNotEmpty) ? lead.branchName : '-')
    ).name;
  }

  String getSelectedDepartmentName() {
    if (departments.isEmpty) return (lead.departmentName != null && lead.departmentName.isNotEmpty) ? lead.departmentName : '-';
    return departments.firstWhere(
      (e) => e.id == (selectedDepartmentId.value ?? 0), 
      orElse: () => DropdownItem(id: 0, name: (lead.departmentName != null && lead.departmentName.isNotEmpty) ? lead.departmentName : '-')
    ).name;
  }

  String getSelectedStaffName() {
    // If it's the logged user, return their name
    if (selectedStaffId.value == loggedUserId.value && loggedUserName.value != null) {
      return loggedUserName.value!;
    }
    // Otherwise look up in staff list
    if (selectedStaffId.value == null) return 'Not Set';
    return staff.firstWhere((e) => e.id == selectedStaffId.value, orElse: () => DropdownItem(id: 0, name: 'Not Found')).name;
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}
