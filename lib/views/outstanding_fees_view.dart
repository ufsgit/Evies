import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/outstanding_fees_controller.dart';
import '../utils/app_theme.dart';
class OutstandingFeesView extends StatelessWidget {
  OutstandingFeesView({super.key});

  final OutstandingFeesController controller = Get.put(OutstandingFeesController());

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppTheme.curvedBorder,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Fees Total Outstanding', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildFilterSection(),
            ),
          ),

          // Fees Table/List
          Obx(() {
            if (controller.isLoading.value && controller.students.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading fees data...', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            if (controller.students.isEmpty) {
              return SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: AppTheme.emptyState('No outstanding fees found', icon: Icons.money_off_rounded),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) return _buildTableHeader();
                    
                    final studentIndex = index - 1;
                    if (studentIndex >= controller.students.length) {
                      if (controller.students.length < controller.totalRecords.value) {
                        controller.loadMore();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: AppTheme.loadingIndicator(size: 24),
                        );
                      }
                      return const SizedBox(height: 120); // Extra space for summary card
                    }

                    final student = controller.students[studentIndex];
                    return _buildFeeRow(student);
                  },
                  childCount: controller.students.length + 2,
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
        borderRadius: BorderRadius.circular(20),
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
                  onPressed: () => controller.fetchFees(),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    controller.fetchFees();
                  },
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        border: Border.all(color: Colors.grey.shade200),
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('ID', 1),
          _buildHeaderCell('NAME', 2),
          _buildHeaderCell('BATCH', 2),
          _buildHeaderCell('STATUS', 2),
          _buildHeaderCell('DUE', 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFeeRow(dynamic student) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              student.studentId.toString(),
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.subtitleColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student.fullName,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student.batchName ?? '-',
              style: GoogleFonts.inter(fontSize: 10, color: AppTheme.subtitleColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: (student.isActive == 1) 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student.isActive == 1 ? 'Active' : 'Inactive',
                style: GoogleFonts.inter(
                  fontSize: 9, 
                  fontWeight: FontWeight.bold, 
                  color: (student.isActive == 1) ? Colors.green : Colors.red
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${student.outstandingAmount ?? '0.00'}',
              style: GoogleFonts.inter(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: Colors.redAccent
              ),
              textAlign: TextAlign.right,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL OUTSTANDING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${summary.outstandingAmount}',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('TOTAL PAID', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(
                        '₹${summary.totalPaidAmount}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

}
