import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Weekly Chart Placeholder
            Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerLight),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 8.w,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Chart visualization will be implemented\nwith fl_chart package',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Monthly Stats
            _buildMonthlyStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(BuildContext context) {
    final monthlyStats = _calculateMonthlyStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        ...monthlyStats.entries.map((entry) {
          final month = entry.key;
          final stats = entry.value;
          final percentage = stats['total'] > 0 
              ? (stats['present'] / stats['total'] * 100).round() 
              : 0;
          
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${stats['present']}/${stats['total']} sessions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(percentage),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      width: 20.w,
                      height: 1.h,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerLight,
                        borderRadius: BorderRadius.circular(0.5.h),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getPercentageColor(percentage),
                            borderRadius: BorderRadius.circular(0.5.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Map<String, Map<String, int>> _calculateMonthlyStats() {
    final Map<String, Map<String, int>> monthlyStats = {};
    
    for (final attendance in filteredAttendance) {
      final monthKey = '${attendance.submittedAt.month}/${attendance.submittedAt.year}';
      
      if (!monthlyStats.containsKey(monthKey)) {
        monthlyStats[monthKey] = {'present': 0, 'total': 0};
      }
      
      monthlyStats[monthKey]!['total'] = monthlyStats[monthKey]!['total']! + 1;
      
      if (attendance.result == AttendanceResult.accepted) {
        monthlyStats[monthKey]!['present'] = monthlyStats[monthKey]!['present']! + 1;
      }
    }
    
    return monthlyStats;
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}