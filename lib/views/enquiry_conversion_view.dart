import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/enquiry_conversion_controller.dart';
import '../utils/app_theme.dart';
import 'enquiry_conversion_details_view.dart';

class EnquiryConversionView extends StatelessWidget {
  EnquiryConversionView({super.key});

  final EnquiryConversionController controller = Get.put(EnquiryConversionController());

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
              title: Text('Enquiry Conversion', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.pie_chart_outline_rounded,
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
              child: _buildFilterSection(context),
            ),
          ),

          // View Toggle Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildToggleSection(),
            ),
          ),

          // Content Area (Table or Graph)
          Obx(() {
            if (controller.isLoadingSummary.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading conversions...', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            if (controller.isErrorSummary.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text('Failed to load data'),
                      TextButton(
                        onPressed: controller.fetchSummary,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.summaryList.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_chart_outlined_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No data found for this period', style: AppTheme.h1.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return controller.isTableView.value ? _buildTableView() : _buildGraphView();
          }),
        ],
      ),
      bottomNavigationBar: Obx(() => controller.isTableView.value && controller.summaryList.isNotEmpty
          ? _buildFooter()
          : const SizedBox.shrink()),
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
          Row(
            children: [
              Obx(() => SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.useCreatedOn.value,
                  onChanged: (val) => controller.useCreatedOn.value = val ?? true,
                  activeColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              )),
              const SizedBox(width: 8),
              Text(
                'Created On',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
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
        if (!controller.useCreatedOn.value) return; // Disable if checkbox is false
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
          color: controller.useCreatedOn.value ? Colors.white : Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: controller.useCreatedOn.value ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateRx.value == null ? label : DateFormat('dd-MM-yyyy').format(dateRx.value!),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: !controller.useCreatedOn.value ? Colors.grey.shade400 : (dateRx.value == null ? Colors.grey.shade500 : AppTheme.textColor),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildToggleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(true, Icons.table_chart_rounded, 'Table'),
          _buildToggleButton(false, Icons.bar_chart_rounded, 'Graph'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool isTableView, IconData icon, String label) {
    return Obx(() {
      final isSelected = controller.isTableView.value == isTableView;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.toggleViewMode(isTableView),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTableView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = controller.summaryList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.enquirySource.toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Navigate to details
                          Get.to(() => EnquiryConversionDetailsView(sourceId: item.sourceId, sourceTitle: item.enquirySource));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('View', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Lead', item.totalLead.toString(), Colors.grey.shade700),
                      _buildStatColumn('Conversion', item.conversionCount.toString(), Colors.green),
                      _buildStatColumn('Percentage', '${item.conversionPercentage.toStringAsFixed(1)}%', Colors.orange.shade800),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: controller.summaryList.length,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildGraphView() {
    final List<Color> pieColors = [
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.brown.shade400,
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPieChartCard('Total Leads by Source', true, pieColors),
            const SizedBox(height: 16),
            _buildPieChartCard('Conversions by Source', false, pieColors),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(String title, bool isTotalLeads, List<Color> colors) {
    final validData = controller.summaryList.where((e) => (isTotalLeads ? e.totalLead : e.conversionCount) > 0).toList();
    
    if (validData.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No data for $title', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(validData.length, (i) {
                        final item = validData[i];
                        final originalIndex = controller.summaryList.indexOf(item);
                        final val = isTotalLeads ? item.totalLead.toDouble() : item.conversionCount.toDouble();
                        return PieChartSectionData(
                          color: colors[originalIndex % colors.length],
                          value: val,
                          title: val.toInt().toString(),
                          radius: 50,
                          titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(validData.length, (i) {
                        final item = validData[i];
                        final originalIndex = controller.summaryList.indexOf(item);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[originalIndex % colors.length], shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.enquirySource,
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GRAND TOTAL', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  'Leads: ${controller.grandTotalLead.value}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Converted: ${controller.grandTotalConversion.value}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text(
                    '${controller.grandTotalPercentage.value.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
