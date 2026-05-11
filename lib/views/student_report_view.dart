import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/student_report_controller.dart';
import '../utils/app_theme.dart';
import 'followup_view.dart';

class StudentReportView extends StatelessWidget {
  StudentReportView({super.key});

  final StudentReportController controller = Get.put(StudentReportController());

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
              title: Text('Student Reports', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_outlined,
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

          // Report Table/List
          Obx(() {
            if (controller.isLoading.value && controller.students.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading student reports...', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            if (controller.students.isEmpty) {
              return SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: AppTheme.emptyState('No student reports found', icon: Icons.search_off_rounded),
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
                      return const SizedBox(height: 100);
                    }

                    final student = controller.students[studentIndex];
                    return _buildStudentRow(student);
                  },
                  childCount: controller.students.length + 2,
                ),
              ),
            );
          }),
        ],
      ),
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
                  (val) {
                    controller.selectedCourseId.value = val;
                    controller.fetchReports();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  'Batch',
                  controller.batches,
                  controller.selectedBatchId,
                  (val) {
                    controller.selectedBatchId.value = val;
                    controller.fetchReports();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Student Name / Phone',
                hintStyle: AppTheme.hintStyle,
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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
          _buildHeaderCell('ACTION', 2),
          _buildHeaderCell('ID', 1),
          _buildHeaderCell('NAME', 3),
          _buildHeaderCell('EMAIL', 3),
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

  Widget _buildStudentRow(dynamic student) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Action
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => Get.to(() => FollowupView(lead: student)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_run_rounded, size: 12, color: Colors.green),
                    const SizedBox(width: 2),
                    Text(
                      'Follow-up',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Student ID
          Expanded(
            flex: 1,
            child: Text(
              student.studentId.toString(),
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.subtitleColor),
            ),
          ),
          // Name
          Expanded(
            flex: 3,
            child: Text(
              student.fullName,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Email
          Expanded(
            flex: 3,
            child: Text(
              student.email.isEmpty ? '-' : student.email,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.subtitleColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}
