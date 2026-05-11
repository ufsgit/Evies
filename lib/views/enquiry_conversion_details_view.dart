import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/enquiry_conversion_controller.dart';
import '../utils/app_theme.dart';

class EnquiryConversionDetailsView extends StatefulWidget {
  final int sourceId;
  final String sourceTitle;

  const EnquiryConversionDetailsView({
    super.key,
    required this.sourceId,
    required this.sourceTitle,
  });

  @override
  State<EnquiryConversionDetailsView> createState() => _EnquiryConversionDetailsViewState();
}

class _EnquiryConversionDetailsViewState extends State<EnquiryConversionDetailsView> {
  final EnquiryConversionController controller = Get.find<EnquiryConversionController>();

  @override
  void initState() {
    super.initState();
    // Schedule fetch after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDetails(widget.sourceId, widget.sourceTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
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
              title: Text('Converted Leads', style: AppTheme.appBarTitle),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.source_rounded, size: 24, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Source: ${widget.sourceTitle.toUpperCase()}',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                    ),
                  ),
                  Obx(() {
                    if (controller.isLoadingDetails.value) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total: ${controller.currentDetailsList.length}',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    );
                  })
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoadingDetails.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTheme.loadingIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading details...', style: AppTheme.subtitle),
                    ],
                  ),
                ),
              );
            }

            if (controller.isErrorDetails.value) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text('Failed to load details'),
                      TextButton(
                        onPressed: () => controller.fetchDetails(widget.sourceId, widget.sourceTitle),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.currentDetailsList.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No converted leads found', style: AppTheme.h1.copyWith(color: Colors.grey)),
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
                    final detail = controller.currentDetailsList[index];
                    return _buildDetailCard(detail);
                  },
                  childCount: controller.currentDetailsList.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(dynamic detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    detail.fullName.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    detail.statusName,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detail.phoneNumber.isNotEmpty ? detail.phoneNumber : 'No Phone',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          detail.email.isNotEmpty ? detail.email : 'No Email',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Created: ${detail.createdOn.split('T')[0]}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
