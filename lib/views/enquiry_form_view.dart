import 'package:aives/models/student_lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enquiry_controller.dart';
import '../models/enquiry_form_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';

class EnquiryFormView extends StatelessWidget {
  final int? studentId;
  final StudentLead? lead;
  final EnquiryController controller = Get.put(EnquiryController());

  EnquiryFormView({super.key, this.studentId, this.lead}) {
    if (lead != null) {
      controller.initWithLead(lead!);
    } else if (studentId != null && studentId! > 0) {
      controller.initForEdit(studentId!);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          studentId != null ? 'Edit Student Lead' : 'Add New Lead',
          style: AppTheme.appBarTitle,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppTheme.curvedBorder,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: AppTheme.curvedBorder,
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.isDropdownLoading.value) {
          return AppTheme.loadingIndicator();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal & Profile Details'),
              const SizedBox(height: 16),
              _buildPersonalDetails(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Student Follow-up'),
              const SizedBox(height: 16),
              _buildFollowupDetails(context),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.h1.copyWith(
        fontSize: 16,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildTextField(
            controller.firstNameController,
            'Full Name*',
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller.emailController,
            'Email',
            Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller.ageController,
                  'Age',
                  Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller.placeController,
                  'Place',
                  Icons.location_on_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 80, child: _buildCountryPickerField(context)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller.phoneController,
                  'Phone Number*',
                  Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller.remarkController,
            'Remark',
            Icons.note_alt_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller.qualificationController,
            'Qualification',
            Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Enquiry Source',
            icon: Icons.source_outlined,
            items: controller.enquirySources,
            valueSelector: () => controller.formData.value.enquirySourceId,
            onChanged: (val) {
              controller.formData.update((data) {
                data?.enquirySourceId = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFollowupDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildDropdownField(
            label: 'Branch',
            icon: Icons.account_tree_outlined,
            items: controller.branches,
            valueSelector: () => controller.formData.value.branchId,
            onChanged: (val) {
              final branch = controller.branches.firstWhere((e) => e.id == val);
              controller.formData.update((data) {
                data?.branchId = val;
                data?.branchName = branch.name;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Department',
            icon: Icons.business_outlined,
            items: controller.departments,
            valueSelector: () => controller.formData.value.departmentId,
            onChanged: (val) {
              final dept = controller.departments.firstWhere((e) => e.id == val);
              controller.formData.update((data) {
                data?.departmentId = val;
                data?.departmentName = dept.name;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Assign To Staff',
            icon: Icons.person_add_alt_1_outlined,
            items: controller.staff,
            valueSelector: () => controller.formData.value.assignedStaffId,
            onChanged: (val) {
              final staffMember = controller.staff.firstWhere((e) => e.id == val);
              controller.formData.update((data) {
                data?.assignedStaffId = val;
                data?.assignedStaffName = staffMember.name;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Follow-up Status',
            icon: Icons.assignment_outlined,
            items: controller.statuses,
            valueSelector: () => controller.formData.value.followUpStatusId,
            onChanged: (val) {
              final status = controller.statuses.firstWhere((e) => e.id == val);
              controller.formData.update((data) {
                data?.followUpStatusId = val;
                data?.followUpStatusName = status.name;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDatePickerField(context),
        ],
      ),
    );
  }

  Widget _buildCountryPickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code', style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                controller.countryCodeController.text = '+${country.phoneCode}';
                controller.formData.update((data) {
                  data?.countryCode = '+${country.phoneCode}';
                  data?.countryCodeName = country.name;
                });
              },
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.circular(20),
                inputDecoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.countryCodeController.text, style: AppTheme.bodyText.copyWith(fontSize: 12)),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            filled: true,
            fillColor: AppTheme.backgroundColor,
          ),
          style: AppTheme.bodyText.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<DropdownItem> items,
    required int? Function() valueSelector,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: items.any((e) => e.id == valueSelector()) ? valueSelector() : null,
              isExpanded: true,
              dropdownColor: AppTheme.cardColor,
              style: AppTheme.bodyText,
              hint: Text('Select $label', style: AppTheme.hintStyle.copyWith(fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
              items: items.map((item) => DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Follow-up Date', style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                child: child!,
              ),
            );
            if (pickedDate != null) {
              controller.formData.update((data) => data?.nextFollowUpDate = DateFormat('yyyy-MM-dd').format(pickedDate));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  controller.formData.value.nextFollowUpDate ?? 'Select Date',
                  style: AppTheme.bodyText.copyWith(
                    color: controller.formData.value.nextFollowUpDate == null ? Colors.grey.shade400 : AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : () => controller.saveEnquiry(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? AppTheme.loadingIndicator(size: 24)
              : Text(
                  studentId != null ? 'Update Student Lead' : 'Save Student Lead',
                  style: AppTheme.h1.copyWith(fontSize: 15, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
