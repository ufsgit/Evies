import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/followup_controller.dart';
import '../models/student_lead_model.dart';
import '../models/enquiry_form_model.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class FollowupView extends StatelessWidget {
  final StudentLead lead;
  final FollowupController controller;

  FollowupView({super.key, required this.lead}) 
      : controller = Get.put(FollowupController(lead: lead));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Student Follow-up', style: AppTheme.appBarTitle),
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
        if (controller.isDropdownLoading.value) {
          return AppTheme.loadingIndicator();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Student Info: ${lead.fullName}'),
              const SizedBox(height: 16),
              _buildFollowupCard(context),
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

  Widget _buildFollowupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Obx(() => _buildInbuiltField(
            'Branch',
            controller.getSelectedBranchName(),
            Icons.account_tree_outlined,
          )),
          const SizedBox(height: 16),
          Obx(() => _buildInbuiltField(
            'Department',
            controller.getSelectedDepartmentName(),
            Icons.business_outlined,
          )),
          const SizedBox(height: 16),
          Obx(() => _buildInbuiltField(
            'Assign To Staff',
            controller.getSelectedStaffName(),
            Icons.person_add_alt_1_outlined,
          )),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Follow-up Status',
            icon: Icons.assignment_outlined,
            items: controller.statuses,
            value: controller.selectedStatusId,
          ),
          const SizedBox(height: 16),
          _buildDatePickerField(context),
          const SizedBox(height: 16),
          _buildTextField(
            controller.remarkController,
            'Remark',
            Icons.note_alt_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
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

  Widget _buildInbuiltField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value, 
                  style: AppTheme.bodyText.copyWith(
                    fontSize: 14, 
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<DropdownItem> items,
    required RxnInt value,
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
            child: Obx(() => DropdownButton<int>(
              value: items.any((e) => e.id == value.value) ? value.value : null,
              isExpanded: true,
              dropdownColor: AppTheme.cardColor,
              style: AppTheme.bodyText,
              hint: Text('Select $label', style: AppTheme.hintStyle.copyWith(fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
              items: items.map((item) => DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name),
              )).toList(),
              onChanged: (val) => value.value = val,
            )),
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
              initialDate: controller.selectedDate.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor)),
                child: child!,
              ),
            );
            if (pickedDate != null) {
              controller.selectedDate.value = pickedDate;
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
                Obx(() => Text(
                  controller.selectedDate.value != null 
                      ? DateFormat('dd-MM-yyyy').format(controller.selectedDate.value!) 
                      : 'Select Date',
                  style: AppTheme.bodyText.copyWith(
                    color: controller.selectedDate.value == null ? Colors.grey.shade400 : AppTheme.textColor,
                  ),
                )),
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
        child: Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : () => controller.saveFollowup(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? AppTheme.loadingIndicator(size: 24)
              : Text(
                  'Save Follow-up',
                  style: AppTheme.h1.copyWith(fontSize: 15, color: Colors.white),
                ),
        )),
      ),
    );
  }
}
