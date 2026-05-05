import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_model.dart';
import '../utils/app_theme.dart';
import 'login_view.dart';
import 'student_lead_view.dart';
import 'call_log_view.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF5C6BC0),
            leading: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.group_add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Get.to(() => StudentLeadView()),
                ),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Dashboard', style: AppTheme.appBarTitle),
              background: Container(
                decoration: const BoxDecoration(
                  borderRadius: AppTheme.curvedBorder,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.hexagon_outlined,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF5C6BC0)),
                  ),
                );
              }

              if (controller.isError.value ||
                  controller.dashboardData.value == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 100.0),
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
                        Text(
                          'Failed to load dashboard',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.fetchDashboardData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C6BC0),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = controller.dashboardData.value!;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leads & Students Bar Chart
                    _buildSectionTitle('Lead & Student Growth'),
                    const SizedBox(height: 16),
                    _buildLeadsStudentsBarChart(
                      data.leadCounts,
                      data.studentCounts,
                    ),
                    const SizedBox(height: 32),

                    // Course Analytics Line Chart
                    _buildSectionTitle('Course Enrollments Trend'),
                    const SizedBox(height: 16),
                    _buildCourseEnrollmentLineChart(data.courses),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: AppTheme.curvedTopBorder,
          boxShadow: AppTheme.navbarShadow,
        ),
        child: ClipRRect(
          borderRadius: AppTheme.curvedTopBorder,
          child: BottomAppBar(
            elevation: 0,
            color: AppTheme.cardColor,
            padding: EdgeInsets.zero,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.dashboard_rounded,
                  'Home',
                  true,
                  onTap: () {},
                ),
                _buildNavItem(
                  Icons.people_alt_rounded,
                  'Leads',
                  false,
                  onTap: () => Get.to(() => StudentLeadView()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppTheme.borderRadiusValue),
          bottomRight: Radius.circular(AppTheme.borderRadiusValue),
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin User',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(Icons.dashboard_rounded, 'Dashboard', true),
                _buildDrawerItem(Icons.school_rounded, 'My Courses', false),
                _buildDrawerItem(Icons.people_rounded, 'Student Leads', false, onTap: () {
                  Get.back();
                  Get.to(() => StudentLeadView());
                }),
                _buildDrawerItem(Icons.analytics_rounded, 'Reports', false),
                _buildDrawerItem(Icons.settings_rounded, 'Settings', false),
                const Divider(indent: 20, endIndent: 20),
                _buildDrawerItem(
                  Icons.logout_rounded,
                  'Logout',
                  false,
                  color: Colors.redAccent,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Get.offAll(() => LoginView());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isActive, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            color ??
            (isActive ? const Color(0xFF5C6BC0) : const Color(0xFF757575)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color:
              color ?? (isActive ? AppTheme.primaryColor : AppTheme.textColor),
        ),
      ),
      onTap:
          onTap ??
          () {
            // Handle navigation
            Get.back();
          },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryColor : const Color(0xFFBDBDBD),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppTheme.primaryColor : const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF212121),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF424242),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsStudentsBarChart(
    List<LeadCount> leads,
    List<StudentCount> students,
  ) {
    if (leads.isEmpty && students.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final leadVal = leads.isNotEmpty ? leads.first.count.toDouble() : 0.0;
    final studentVal = students.isNotEmpty
        ? students.first.count.toDouble()
        : 0.0;
    final month = leads.isNotEmpty
        ? leads.first.month
        : (students.isNotEmpty ? students.first.month : '');

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem('Leads', const Color(0xFF90CAF9)),
              const SizedBox(width: 16),
              _buildLegendItem('Students', const Color(0xFFE1BEE7)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (leadVal > studentVal ? leadVal : studentVal) * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            month,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF757575),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF757575),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFEEEEEE),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: leadVal,
                        color: const Color(0xFF90CAF9),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: studentVal,
                        color: const Color(0xFFE1BEE7),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseEnrollmentLineChart(List<CourseEnrollment> courses) {
    if (courses.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = courses.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.enrollmentCount.toDouble());
    }).toList();

    double maxY = courses
        .map((c) => c.enrollmentCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    if (maxY == 0) maxY = 10; // Prevent div by zero on interval

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 5) > 0 ? maxY / 5 : 1,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFEEEEEE),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= courses.length) {
                          return const SizedBox.shrink();
                        }

                        String name = courses[index].courseName;
                        if (name.length > 10) {
                          name = '${name.substring(0, 10)}...';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF757575),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF757575),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (courses.length - 1).toDouble(),
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF5C6BC0),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF5C6BC0),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5C6BC0).withValues(alpha: 0.3),
                          const Color(0xFF5C6BC0).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
