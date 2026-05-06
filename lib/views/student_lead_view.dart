import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/student_lead_controller.dart';
import '../controllers/enquiry_controller.dart';
import '../models/student_lead_model.dart';
import '../models/dropdown_models.dart';
import 'followup_view.dart';
import '../utils/app_theme.dart';
import 'enquiry_form_view.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentLeadView extends StatelessWidget {
  StudentLeadView({super.key});

  final StudentLeadController controller = Get.put(StudentLeadController());

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Call Error',
          'Could not launch dialer',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchWhatsApp(String? countryCode, String phoneNumber) async {
    String cleanCode = (countryCode ?? '+91').replaceAll('+', '');
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // App schemes for both WhatsApp and WhatsApp Business usually respond to this
    final Uri appUrl = Uri.parse('whatsapp://send?phone=$cleanCode$cleanPhone');
    final Uri webUrl = Uri.parse('https://wa.me/$cleanCode$cleanPhone');

    try {
      // We try launching the app scheme first. 
      // Note: canLaunchUrl requires <queries> in AndroidManifest to work on Android 11+
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else if (await canLaunchUrl(webUrl)) {
        // Fallback to the deep link which handles redirection to either app
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'WhatsApp Error',
          'WhatsApp is not installed on this device',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(15),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while launching WhatsApp',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppTheme.curvedBorder,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Student Leads', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),

          // Search Bar & Filters Inset
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: TextField(
                      onChanged: (val) {
                        controller.searchTerm.value = val;
                        controller.onSearchChange();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or contact...',
                        hintStyle: AppTheme.hintStyle,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Staff Filter
                        Obx(
                          () => _buildDropdownChip<StaffModel?>(
                            label: controller.selectedStaffId.value == null
                                ? 'All Staff'
                                : controller.staff
                                      .firstWhere(
                                        (s) =>
                                            s.id ==
                                            controller.selectedStaffId.value,
                                        orElse: () =>
                                            StaffModel(id: 0, name: 'Unknown'),
                                      )
                                      .name,
                            icon: Icons.person_search_rounded,
                            items: controller.staff,
                            onSelected: (staff) {
                              controller.selectedStaffId.value = staff?.id;
                              controller.onSearchChange();
                            },
                          ),
                        ),

                        // Status Filter
                        Obx(
                          () => _buildDropdownChip<FollowupStatusModel?>(
                            label: controller.selectedStatus.value == 'all'
                                ? 'All Followups'
                                : controller.statuses
                                      .firstWhere(
                                        (s) =>
                                            s.id.toString() ==
                                            controller.selectedStatus.value,
                                        orElse: () => FollowupStatusModel(
                                          id: 0,
                                          name: 'Unknown',
                                        ),
                                      )
                                      .name,
                            icon: Icons.history_rounded,
                            items: controller.statuses,
                            onSelected: (status) {
                              controller.selectedStatus.value =
                                  status?.id.toString() ?? 'all';
                              controller.onSearchChange();
                            },
                          ),
                        ),

                        // Branch Filter
                        Obx(
                          () => _buildDropdownChip<BranchModel?>(
                            label: controller.selectedBranchId.value == null
                                ? 'All Branches'
                                : controller.branches
                                      .firstWhere(
                                        (b) =>
                                            b.id ==
                                            controller.selectedBranchId.value,
                                        orElse: () =>
                                            BranchModel(id: 0, name: 'Unknown'),
                                      )
                                      .name,
                            icon: Icons.location_on_rounded,
                            items: controller.branches,
                            onSelected: (branch) {
                              controller.selectedBranchId.value = branch?.id;
                              controller.onSearchChange();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Result Count Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          'Total Results: ${controller.totalLeads.value}',
                          style: AppTheme.h1.copyWith(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          'Page ${controller.currentPage.value}',
                          style: AppTheme.subtitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lead List
          Obx(() {
            if (controller.isLoading.value) {
              return SliverFillRemaining(child: AppTheme.loadingIndicator());
            }

            if (controller.isError.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text('Failed to load leads'),
                      TextButton(
                        onPressed: controller.fetchStudentLeads,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.filteredLeads.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text('No leads found')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                  children: [
                    _buildLeadCard(controller.filteredLeads[index]),
                    if (index < controller.filteredLeads.length - 1)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEEEEEE),
                      ),
                  ],
                );
              }, childCount: controller.filteredLeads.length),
            );
          }),

          // Pagination Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                if (controller.totalLeads.value == 0)
                  return const SizedBox.shrink();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageButton(
                      Icons.chevron_left_rounded,
                      controller.currentPage.value > 1
                          ? controller.previousPage
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${controller.currentPage.value}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildPageButton(
                      Icons.chevron_right_rounded,
                      (controller.currentPage.value *
                                  controller.itemsPerPage.value <
                              controller.totalLeads.value)
                          ? controller.nextPage
                          : null,
                    ),
                  ],
                );
              }),
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Action Button for Add Enquiry
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Get.put(EnquiryController()).resetForm();
          final result = await Get.to(() => EnquiryFormView());
          if (result == true) {
            controller.fetchStudentLeads();
          }
        },

        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Enquiry',
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip<T>({
    required String label,
    required IconData icon,
    required List<T> items,
    required Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        // "All" option
        PopupMenuItem<T>(
          value: null as T,
          child: Text(
            label.startsWith('All') ? label : 'Clear Filter',
            style: AppTheme.bodyText.copyWith(color: AppTheme.primaryColor),
          ),
        ),
        ...items.map((item) {
          String itemName = '';
          if (item is StaffModel) itemName = item.name;
          if (item is BranchModel) itemName = item.name;
          if (item is FollowupStatusModel) itemName = item.name;

          return PopupMenuItem<T>(
            value: item,
            child: Text(itemName, style: AppTheme.bodyText),
          );
        }),
      ],
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.subtitleColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.subtitle.copyWith(color: const Color(0xFF424242)),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null
              ? AppTheme.primaryColor
              : Colors.grey.shade400,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLeadCard(StudentLead lead) {
    return InkWell(
      onTap: () async {
        final result = await Get.to(() => FollowupView(lead: lead));
        if (result == true) {
          controller.fetchStudentLeads();
        }
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lead.fullName.toUpperCase(),
                      style: AppTheme.bodyText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Get.to(
                        () => EnquiryFormView(
                          studentId: lead.studentId,
                          lead: lead,
                        ),
                      );
                      if (result == true) {
                        controller.fetchStudentLeads();
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lead.statusName,
                      style: AppTheme.bodyText.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Phone and Remark
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phone Number
                        const SizedBox(height: 2),
                        Text(
                          lead.phoneNumber,
                          style: AppTheme.subtitle.copyWith(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Remark
                        if (lead.remark.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            lead.remark,
                            style: AppTheme.subtitle.copyWith(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Right Side: Action Icons (Compact Row)
                  Row(
                    children: [
                      _buildCompactActionIcon(
                        Icons.call_outlined,
                        Colors.blue,
                        () {
                          _makeCall(lead.phoneNumber);
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildCompactActionIcon(
                        null,
                        Colors.green,
                        () {
                          _launchWhatsApp(lead.countryCode, lead.phoneNumber);
                        },
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/3670/3670051.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildCompactActionIcon(
                        Icons.history_rounded,
                        Colors.orange,
                        () async {
                          final result = await Get.to(
                            () => FollowupView(lead: lead),
                          );
                          if (result == true) {
                            controller.fetchStudentLeads();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionIcon(
    IconData? icon,
    Color color,
    VoidCallback onTap, {
    Widget? child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: child ?? Icon(icon, size: 22, color: color),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
