import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/work_report_controller.dart';
import '../utils/app_theme.dart';
import 'work_report_details_view.dart';
class WorkReportView extends StatelessWidget {
  WorkReportView({super.key});

  final WorkReportController controller = Get.put(WorkReportController());

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
              title: Text('Work Report', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
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
              child: _buildFilterSection(context),
            ),
          ),

          // Data Table Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildTableHeader(),
            ),
          ),

          // Summary List
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.summaryList.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No staff records found', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.summaryList[index];
                    return _buildStaffRow(index + 1, item);
                  },
                  childCount: controller.summaryList.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: _buildDateDisplay(
                  'FROM DATE',
                  controller.fromDate,
                  () => controller.selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateDisplay(
                  'TO DATE',
                  controller.toDate,
                  () => controller.selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Obx(() => Switch.adaptive(
                    value: controller.useCreatedDate.value == 1,
                    onChanged: (val) => controller.toggleDateFilter(),
                    activeColor: AppTheme.primaryColor,
                  )),
                  Text(
                    'Created On',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => controller.fetchSummary(),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(String label, RxString dateRx, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  dateRx.value,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                )),
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildHeaderText('NO')),
          Expanded(flex: 4, child: _buildHeaderText('BY STAFF')),
          Expanded(flex: 2, child: _buildHeaderText('FOLLOW UP')),
          const SizedBox(width: 80), // Space for action button
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStaffRow(int index, dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              index.toString(),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item.staffName,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.followUpCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextButton(
              onPressed: () => Get.to(() => WorkReportDetailsView(staffId: item.staffId, staffName: item.staffName)),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'View Details',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
