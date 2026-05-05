import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/student_lead_controller.dart';
import '../controllers/enquiry_controller.dart';
import '../models/student_lead_model.dart';

import '../utils/app_theme.dart';
import 'widgets/enquiry_form_popup.dart';

class StudentLeadView extends StatelessWidget {
  StudentLeadView({super.key});

  final StudentLeadController controller = Get.put(StudentLeadController());

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
                      onChanged: controller.filterLeads,
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

                  // Filter Chips (Placeholder for Staff, Status, Branch)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Staff', Icons.person_outline),
                        _buildFilterChip('All Followups', Icons.event_note),
                        _buildFilterChip(
                          'All Branches',
                          Icons.account_tree_outlined,
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
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF5C6BC0)),
                ),
              );
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

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildLeadCard(controller.filteredLeads[index]);
                }, childCount: controller.filteredLeads.length),
              ),
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
          final result = await Get.dialog(EnquiryFormPopup());
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

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    lead.firstName[0],
                    style: AppTheme.h1.copyWith(
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lead.fullName,
                            style: AppTheme.bodyText.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final result = await Get.dialog(
                                EnquiryFormPopup(
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
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF81C784,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lead.statusName,
                              style: AppTheme.bodyText.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.phoneNumber,
                        style: AppTheme.subtitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Follow-up: ${lead.followUpDate?.split('T')[0] ?? 'N/A'}',
                            style: AppTheme.subtitle.copyWith(
                              color: AppTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lead.assignedStaffName,
                            style: AppTheme.subtitle.copyWith(
                              color: AppTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remark Section
          if (lead.remark.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.cardRadiusValue),
                  bottomRight: Radius.circular(AppTheme.cardRadiusValue),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lead.remark,
                      style: AppTheme.subtitle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
