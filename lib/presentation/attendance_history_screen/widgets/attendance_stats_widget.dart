import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AttendanceStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> filteredStats;

  const AttendanceStatsWidget({
    Key? key,
    required this.stats,
    required this.filteredStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Overall Stats
            _buildStatsRow(
              context,
              'Overall Attendance',
              '${stats['percentage']}%',
              '${stats['present']}/${stats['total']}',
              AppTheme.primaryLight,
            ),
            
            SizedBox(height: 2.h),
            
            // Filtered Stats (if different from overall)
            if (filteredStats['total'] != stats['total'])
              Column(
                children: [
                  _buildStatsRow(
                    context,
                    'Filtered Attendance',
                    '${filteredStats['percentage']}%',
                    '${filteredStats['present']}/${filteredStats['total']}',
                    AppTheme.secondaryLight,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            
            // Detailed Breakdown
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Present',
                    stats['present'].toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Absent',
                    stats['absent'].toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    String title,
    String percentage,
    String count,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                count,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
          Text(
            percentage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}