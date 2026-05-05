import 'package:aives/models/student_lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enquiry_controller.dart';
import '../../models/enquiry_form_model.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';

class EnquiryFormPopup extends StatelessWidget {
  final int? studentId;
  final StudentLead? lead;
  final EnquiryController controller = Get.put(EnquiryController());

  EnquiryFormPopup({super.key, this.studentId, this.lead}) {
    if (lead != null) {
      controller.initWithLead(lead!);
    } else if (studentId != null && studentId! > 0) {
      controller.initForEdit(studentId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Form Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value ||
                    controller.isDropdownLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
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
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            studentId != null ? 'Edit Student Lead' : 'Add New Lead',
            style: AppTheme.h1.copyWith(fontSize: 18),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.bodyText.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller.firstNameController,
          'Full Name*',
          Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller.emailController,
          'Email',
          Icons.email_outlined,
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 90, child: _buildCountryPickerField(context)),
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
        const SizedBox(height: 12),
        _buildTextField(
          controller.altPhoneController,
          'Alternative Number',
          Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),

        const SizedBox(height: 12),
        _buildTextField(
          controller.qualificationController,
          'Qualifications',
          Icons.school_outlined,
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildFollowupDetails(BuildContext context) {
    return Column(
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        _buildDatePickerField(context),
        const SizedBox(height: 12),
        _buildTextField(
          controller.remarkController,
          'Remark',
          Icons.note_alt_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCountryPickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code',
          style: AppTheme.bodyText.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                  hintText: 'Search country...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.countryCodeController.text,
                  style: AppTheme.bodyText.copyWith(fontSize: 13),
                ),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
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
        Text(
          label,
          style: AppTheme.bodyText.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
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
        Text(
          label,
          style: AppTheme.bodyText.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            int? value = valueSelector();
            // Safety check: ensure the value exists in the items list to prevent crash
            int? safeValue = value;
            if (safeValue != null &&
                !items.any((item) => item.id == safeValue)) {
              safeValue = null;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: safeValue,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: AppTheme.bodyText.copyWith(color: Colors.black87),
                  hint: Text('Select $label', style: AppTheme.hintStyle),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(
                        item.name,
                        style: AppTheme.bodyText.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Follow-up Date',
          style: AppTheme.bodyText.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat(
                'yyyy-MM-dd',
              ).format(pickedDate);
              controller.formData.update((data) {
                data?.nextFollowUpDate = formattedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.formData.value.nextFollowUpDate ?? 'Select Date',
                  style: AppTheme.bodyText.copyWith(
                    color: controller.formData.value.nextFollowUpDate == null
                        ? Colors.grey.shade400
                        : AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.bodyText.copyWith(color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.saveEnquiry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Student',
                        style: AppTheme.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
