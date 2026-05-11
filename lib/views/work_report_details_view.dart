import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/work_report_controller.dart';
import '../utils/app_theme.dart';

class WorkReportDetailsView extends StatefulWidget {
  final int staffId;
  final String staffName;

  const WorkReportDetailsView({super.key, required this.staffId, required this.staffName});

  @override
  State<WorkReportDetailsView> createState() => _WorkReportDetailsViewState();
}

class _WorkReportDetailsViewState extends State<WorkReportDetailsView> {
  final WorkReportController controller = Get.find<WorkReportController>();

  @override
  void initState() {
    super.initState();
    controller.fetchDetails(widget.staffId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Activity Details', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.staffName, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: Obx(() {
              if (controller.isDetailsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.detailsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No activity records for this period', style: AppTheme.subtitle),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.detailsList.length,
                itemBuilder: (context, index) {
                  final detail = controller.detailsList[index];
                  return _buildActivityCard(detail);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
          const SizedBox(width: 8),
          Obx(() => Text(
            '${controller.fromDate.value} to ${controller.toDate.value}',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityCard(dynamic detail) {
    final String studentName = detail.studentName.isNotEmpty ? detail.studentName : 'Unknown Student';
    final String status = detail.statusName.isNotEmpty ? detail.statusName : 'No Status';
    final String entryDate = detail.entryDate.isNotEmpty ? detail.entryDate.split('T')[0] : 'N/A';
    final String followUpDate = detail.followUpDate.isNotEmpty ? detail.followUpDate.split('T')[0] : 'N/A';
    
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail.departmentName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            detail.departmentName,
                            style: GoogleFonts.inter(fontSize: 10, color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: status == 'No Status' ? Colors.grey.shade100 : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      color: status == 'No Status' ? Colors.grey.shade600 : AppTheme.primaryColor
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.phone_rounded, detail.phoneNumber.isNotEmpty ? detail.phoneNumber : 'No Mobile'),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.event_rounded, 'Entry: $entryDate'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.person_outline_rounded, 'Assigned: ${detail.assignedTo.isNotEmpty ? detail.assignedTo : 'None'}'),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.update_rounded, 'F/U Date: $followUpDate'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.how_to_reg_rounded, 'Follow Up By: ${detail.followUpBy.isNotEmpty ? detail.followUpBy : 'Unknown'}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, thickness: 0.5),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    detail.remark.isEmpty || detail.remark == '-' ? 'No remark provided' : detail.remark,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
