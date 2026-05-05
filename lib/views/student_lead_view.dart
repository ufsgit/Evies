import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/student_lead_controller.dart';
import '../models/student_lead_model.dart';

class StudentLeadView extends StatelessWidget {
  StudentLeadView({super.key});

  final StudentLeadController controller = Get.put(StudentLeadController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF5C6BC0),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Student Leads',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF90CAF9), // Light Blue
                      Color(0xFFE1BEE7), // Light Purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.filterLeads,
                      decoration: InputDecoration(
                        hintText: 'Search by name or contact...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5C6BC0)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                        _buildFilterChip('All Branches', Icons.account_tree_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Result Count Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                        'Total Results: ${controller.totalLeads.value}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C6BC0),
                        ),
                      )),
                      Obx(() => Text(
                        'Page ${controller.currentPage.value}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      )),
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
                child: Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0))),
              );
            }

            if (controller.isError.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text('Failed to load leads'),
                      TextButton(onPressed: controller.fetchStudentLeads, child: const Text('Retry')),
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildLeadCard(controller.filteredLeads[index]);
                  },
                  childCount: controller.filteredLeads.length,
                ),
              ),
            );
          }),

          // Pagination Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                if (controller.totalLeads.value == 0) return const SizedBox.shrink();
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageButton(
                      Icons.chevron_left_rounded,
                      controller.currentPage.value > 1 ? controller.previousPage : null,
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
                      (controller.currentPage.value * controller.itemsPerPage.value < controller.totalLeads.value)
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
        onPressed: () {},
        backgroundColor: const Color(0xFF5C6BC0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Enquiry', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF757575)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF424242), fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF757575)),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? const Color(0xFF5C6BC0).withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: onPressed != null ? const Color(0xFF5C6BC0) : Colors.grey.shade400),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLeadCard(StudentLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  backgroundColor: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                  child: Text(
                    lead.firstName[0],
                    style: GoogleFonts.poppins(color: const Color(0xFF5C6BC0), fontWeight: FontWeight.bold),
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
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF212121),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lead.statusName,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.phoneNumber,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            'Follow-up: ${lead.followUpDate?.split('T')[0] ?? 'N/A'}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            lead.assignedStaffName,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
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
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lead.remark,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
