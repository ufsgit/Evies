import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/enquiry_summary_controller.dart';
import '../utils/app_theme.dart';
class EnquirySummaryView extends StatelessWidget {
  EnquirySummaryView({super.key});

  final EnquirySummaryController controller = Get.put(EnquirySummaryController());

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
              title: Text('Enquiry Summary', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // Filters Inset
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildFilterSection(context),
            ),
          ),

          // Summary Table
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: AppTheme.loadingIndicator(),
                  );
                }
                if (controller.isError.value || controller.summaryData.value == null) {
                  return _buildErrorState();
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildSummaryTable(),
                );
              }),
            ),
          ),
          
          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Filter',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  context,
                  'From Date',
                  controller.fromDate,
                  (date) => controller.setFromDate(date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  context,
                  'To Date',
                  controller.toDate,
                  (date) => controller.setToDate(date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.fetchSummary,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                'Search',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, Rxn<DateTime> dateRx, Function(DateTime) onSelect) {
    return Obx(() => GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dateRx.value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
              ),
              child: child!,
            );
          },
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              dateRx.value == null ? label : DateFormat('dd-MM-yyyy').format(dateRx.value!),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: dateRx.value == null ? Colors.grey.shade500 : AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSummaryTable() {
    final data = controller.summaryData.value!;
    
    if (data.sources.isEmpty || data.statuses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: AppTheme.emptyState('No enquiry summary data available for this date range.'),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.05)),
        columnSpacing: 32,
        horizontalMargin: 20,
        headingRowHeight: 56,
        dataRowHeight: 52,
        columns: [
          DataColumn(
            label: Text(
              'ENQUIRY SOURCE', 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...data.statuses.map((s) => DataColumn(
            label: Text(
              s.name.toUpperCase(), 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          )),
          DataColumn(
            label: Text(
              'GRAND TOTAL', 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        rows: [
          ...data.sources.map((source) => DataRow(
            cells: [
              DataCell(
                Text(
                  source.name, 
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              ...data.statuses.map((status) => DataCell(
                Center(
                  child: Text(
                    controller.getCount(source.id, status.id).toString(),
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              )),
              DataCell(
                Center(
                  child: Text(
                    controller.getRowTotal(source.id).toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          )),
          DataRow(
            color: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.1)),
            cells: [
              DataCell(
                Text(
                  'GRAND TOTAL', 
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              ...data.statuses.map((status) => DataCell(
                Center(
                  child: Text(
                    controller.getColumnTotal(status.id).toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              )),
              DataCell(
                Center(
                  child: Text(
                    controller.getGrandTotal().toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Failed to load summary', style: AppTheme.bodyText),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchSummary,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}
