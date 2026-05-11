import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/upcoming_installment_controller.dart';
import '../utils/app_theme.dart';
class UpcomingInstallmentView extends StatelessWidget {
  UpcomingInstallmentView({super.key});

  final UpcomingInstallmentController controller = Get.put(UpcomingInstallmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Premium Gradient App Bar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppTheme.curvedBorder,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Upcoming Installment', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ),

          // Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _buildFilterSection(),
            ),
          ),

          // Data Cards List
          Obx(() {
            if (controller.isLoading.value && controller.installments.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingIndicator(),
                      const SizedBox(height: 16),
                      Text('Fetching installments...', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            if (controller.installments.isEmpty) {
              return SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: AppTheme.emptyState('No upcoming installments', icon: Icons.event_available_rounded),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= controller.installments.length) {
                      if (controller.installments.length < controller.totalRecords.value) {
                        controller.loadMore();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: AppTheme.loadingIndicator(size: 24),
                        );
                      }
                      return const SizedBox(height: 100); // Space for bottom card
                    }

                    final item = controller.installments[index];
                    return _buildInstallmentCard(item);
                  },
                  childCount: controller.installments.length + 1,
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildSummaryCard(),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'Course',
                  controller.courses,
                  controller.selectedCourseId,
                  (val) => controller.selectedCourseId.value = val,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  'Student',
                  controller.studentDropdown,
                  controller.selectedStudentId,
                  (val) => controller.selectedStudentId.value = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            'Batch',
            controller.batches,
            controller.selectedBatchId,
            (val) => controller.selectedBatchId.value = val,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.fetchInstallments(),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.selectedCourseId.value = null;
                    controller.selectedStudentId.value = null;
                    controller.selectedBatchId.value = null;
                    controller.fetchInstallments();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items, Rxn<int> valueRx, Function(int?) onChanged) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: valueRx.value,
          isExpanded: true,
          hint: Text(label, style: AppTheme.hintStyle.copyWith(fontSize: 12)),
          items: [
            DropdownMenuItem<int>(value: null, child: Text('All $label', style: const TextStyle(fontSize: 12))),
            ...items.map((e) => DropdownMenuItem<int>(
              value: e.id,
              child: Text(e.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    ));
  }

  Widget _buildInstallmentCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 100,
                color: AppTheme.primaryColor.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: ${item.studentId}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        item.nextDueDate != null ? item.nextDueDate!.split('T')[0] : 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.email,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.subtitleColor),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    children: [
                      _buildInfoTag(Icons.grid_view_rounded, item.batchName ?? 'No Batch'),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'UPCOMING',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹${item.upcomingAmount ?? '0.00'}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.subtitleColor),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      if (controller.summary.value == null) return const SizedBox.shrink();
      
      final summary = controller.summary.value!;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL UPCOMING',
                    style: GoogleFonts.inter(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${summary.outstandingAmount}',
                    style: GoogleFonts.inter(
                      fontSize: 22, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      );
    });
  }

}
