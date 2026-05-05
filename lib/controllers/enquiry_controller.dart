import 'package:aives/models/student_lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enquiry_form_model.dart';
import '../network/api_endpoints.dart';
import '../network/student_lead_repository.dart';

class EnquiryController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = false.obs;
  var isDropdownLoading = false.obs;

  // Dropdown Lists
  var branches = <DropdownItem>[].obs;
  var departments = <DropdownItem>[].obs;
  var statuses = <DropdownItem>[].obs;
  var staff = <DropdownItem>[].obs;
  var enquirySources = <DropdownItem>[].obs;

  // Form Data
  var formData = EnquiryFormData().obs;

  // Controllers for text fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController altPhoneController;
  late TextEditingController ageController;
  late TextEditingController qualificationController;
  late TextEditingController qualificationDescController;
  late TextEditingController placeController;
  late TextEditingController remarkController;
  late TextEditingController countryCodeController;

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    altPhoneController = TextEditingController();
    ageController = TextEditingController();
    qualificationController = TextEditingController();
    qualificationDescController = TextEditingController();
    placeController = TextEditingController();
    remarkController = TextEditingController();
    countryCodeController = TextEditingController(text: '+91');

    fetchDropdowns();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    ageController.dispose();
    qualificationController.dispose();
    qualificationDescController.dispose();
    placeController.dispose();
    remarkController.dispose();
    countryCodeController.dispose();
    super.onClose();
  }

  void resetForm() {
    formData.value = EnquiryFormData();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    altPhoneController.clear();
    ageController.clear();
    qualificationController.clear();
    qualificationDescController.clear();
    placeController.clear();
    remarkController.clear();
    countryCodeController.text = '+91';
  }

  void fetchDropdowns() async {
    if (isDropdownLoading.value) return;
    isDropdownLoading(true);

    try {
      final results = await Future.wait([
        _repository.fetchDropdown(ApiEndpoints.branchDropdown),
        _repository.fetchDropdown(ApiEndpoints.departmentDropdown),
        _repository.fetchDropdown(ApiEndpoints.getFollowupStatus),
        _repository.fetchDropdown(ApiEndpoints.userDropdown),
        _repository.fetchDropdown(ApiEndpoints.enquirySourceDropdown),
      ]);

      branches.assignAll(
        results[0]
            .map(
              (e) => DropdownItem.fromJson(
                e,
                idKey: 'Branch_Id',
                nameKey: 'Branch_Name',
              ),
            )
            .toList(),
      );
      departments.assignAll(
        results[1]
            .map(
              (e) => DropdownItem.fromJson(
                e,
                idKey: 'Department_Id',
                nameKey: 'Department_Name',
              ),
            )
            .toList(),
      );
      statuses.assignAll(
        results[2]
            .map(
              (e) => DropdownItem.fromJson(
                e,
                idKey: 'Status_Id',
                nameKey: 'Status_Name',
              ),
            )
            .toList(),
      );
      staff.assignAll(
        results[3].map((e) {
          // Robust name selection: try multiple possible keys from the API
          String name =
              (e['FirstName'] ??
                      e['First_Name'] ??
                      e['User_Name'] ??
                      e['To_User_Name'] ??
                      'Staff')
                  .toString()
                  .trim();
          if (name.isEmpty || name == 'null') name = 'Staff Member';

          return DropdownItem(
            id: e['User_ID'] ?? e['User_Id'] ?? 0,
            name: name,
          );
        }).toList(),
      );

      // Ensure unique IDs to prevent dropdown crashes
      var uniqueStaff = <int, DropdownItem>{};
      for (var s in staff) {
        if (!uniqueStaff.containsKey(s.id)) {
          uniqueStaff[s.id] = s;
        }
      }
      staff.assignAll(uniqueStaff.values.toList());

      enquirySources.assignAll(
        results[4]
            .map(
              (e) => DropdownItem.fromJson(
                e,
                idKey: 'Enquiry_Source_Id',
                nameKey: 'Enquiry_Source_Name',
              ),
            )
            .toList(),
      );
    } finally {
      isDropdownLoading(false);
    }
  }

  void initWithLead(StudentLead lead) {
    // Reset first to be safe
    resetForm();
    
    formData.update((data) {
      if (data == null) return;
      data.studentId = lead.studentId;
      data.firstName = lead.firstName;
      data.lastName = lead.lastName;
      data.email = lead.email;
      data.phoneNumber = lead.phoneNumber;
      data.countryCode = lead.countryCode ?? '+91';
      data.countryCodeName = lead.countryCodeName ?? 'India';
      data.followUpDate = lead.followUpDate;
      data.followUpStatusId = lead.statusId;
      data.followUpStatusName = lead.statusName;
      data.assignedStaffId = lead.assignedStaffId;

      data.assignedStaffName = lead.assignedStaffName;
      data.remark = lead.remark;
      data.address = lead.address ?? '';
      data.age = lead.age ?? 0;
      data.qualification = lead.qualification ?? '';
      data.branchId = lead.branchId;
      data.departmentId = lead.departmentId;
      data.enquirySourceId = lead.enquirySourceId;
    });

    // Update text controllers
    firstNameController.text = lead.firstName;
    lastNameController.text = lead.lastName;
    emailController.text = lead.email;
    phoneController.text = lead.phoneNumber;
    countryCodeController.text = lead.countryCode ?? '+91';
    ageController.text = (lead.age ?? 0).toString();
    qualificationController.text = lead.qualification ?? '';
    placeController.text = lead.address ?? '';
    remarkController.text = lead.remark;
    
    // Note: We don't call isLoading(true) or any API here!
  }

  void initForEdit(int studentId) async {

    isLoading(true);
    try {
      final response = await _repository.getStudentDetails(studentId);

      // The API returns a nested list: [ [studentData], {metaData} ]
      if (response != null && response is List && response.isNotEmpty && response[0] is List && response[0].isNotEmpty) {
        final data = response[0][0]; // Extract the actual student object
        formData.value = EnquiryFormData.fromLead(data);

        // Update controllers with the extracted data
        firstNameController.text = formData.value.firstName;
        lastNameController.text = formData.value.lastName;
        emailController.text = formData.value.email;
        phoneController.text = formData.value.phoneNumber;
        altPhoneController.text = formData.value.altPhoneNumber;
        ageController.text = formData.value.age.toString();
        qualificationController.text = formData.value.qualification;
        placeController.text = formData.value.address;
        remarkController.text = formData.value.remark;
        countryCodeController.text = formData.value.countryCode;
      }
    } catch (e) {
      debugPrint('Error initializing edit mode: $e');
    } finally {
      isLoading(false);
    }

  }

  void saveEnquiry() async {
    if (firstNameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'First Name and Phone Number are required',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Email validation (only if email is not empty)
    if (emailController.text.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text)) {
        Get.snackbar(
          'Invalid Email',
          'Please enter a valid email address',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    isLoading(true);
    try {
      // Update formData from controllers
      formData.value.firstName = firstNameController.text;
      formData.value.lastName = lastNameController.text;
      formData.value.email = emailController.text;
      formData.value.phoneNumber = phoneController.text;
      formData.value.altPhoneNumber = altPhoneController.text;
      formData.value.age = int.tryParse(ageController.text) ?? 0;
      formData.value.qualification = qualificationController.text;
      formData.value.address = placeController.text;
      formData.value.remark = remarkController.text;
      formData.value.countryCode = countryCodeController.text;

      final success = await _repository.saveStudent(formData.value.toJson());
      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Enquiry saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save enquiry',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
