import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../models/attendance_model.dart';

class AttendanceChartWidget extends StatelessWidget {
  final List<AttendanceModel> attendanceHistory;
  final List<AttendanceModel> filteredAttendance;

  const AttendanceChartWidget({
    Key? key,
    required this.attendanceHistory,
    required this.filteredAttendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attendanceHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64.sp,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'No data available for charts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pie Chart
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  height: 40.h,
                  child: PieChart(
                    PieChartData(
                      sections: _getPieChartSections(context),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                _buildLegend(context),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Weekly Bar Chart
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Attendance Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  height: 30.h,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 7,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                );
                              }
                              return const Text('');
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getWeeklyBarGroups(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections(BuildContext context) {
    final present = attendanceHistory.where((a) => a.status == AttendanceStatus.present).length;
    final absent = attendanceHistory.where((a) => a.status == AttendanceStatus.absent).length;
    final late = attendanceHistory.where((a) => a.status == AttendanceStatus.late).length;
    final total = attendanceHistory.length;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: AppTheme.successLight,
        value: present.toDouble(),
        title: '${(present / total * 100).round()}%',
        radius: 50,
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.errorLight,
        value: absent.toDouble(),
        title: '${(absent / total * 100).round()}%',
        radius: 50,
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.warningLight,
        value: late.toDouble(),
        title: '${(late / total * 100).round()}%',
        radius: 50,
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(context, 'Present', AppTheme.successLight, Icons.check_circle),
        _buildLegendItem(context, 'Absent', AppTheme.errorLight, Icons.cancel),
        _buildLegendItem(context, 'Late', AppTheme.warningLight, Icons.schedule),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 1.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getWeeklyBarGroups() {
    // Group attendance by day of week
    final weeklyData = List.generate(7, (index) => 0);
    
    for (final attendance in attendanceHistory) {
      final dayOfWeek = attendance.timestamp.weekday - 1; // Monday = 0
      if (attendance.status == AttendanceStatus.present) {
        weeklyData[dayOfWeek]++;
      }
    }

    return weeklyData.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppTheme.primaryLight,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}
