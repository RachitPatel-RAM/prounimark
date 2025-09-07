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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Statistics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Overall Stats
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
                  'Overall Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Classes',
                        stats['total'].toString(),
                        Icons.school,
                        AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Present',
                        stats['present'].toString(),
                        Icons.check_circle,
                        AppTheme.successLight,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Absent',
                        stats['absent'].toString(),
                        Icons.cancel,
                        AppTheme.errorLight,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Late',
                        stats['late'].toString(),
                        Icons.schedule,
                        AppTheme.warningLight,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.h),
                
                // Attendance Percentage
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(stats['percentage']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPercentageColor(stats['percentage']).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.percent,
                        color: _getPercentageColor(stats['percentage']),
                        size: 24.sp,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Percentage',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${stats['percentage']}%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: _getPercentageColor(stats['percentage']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Filtered Stats (if filters are applied)
        if (_hasFiltersApplied()) ...[
          SizedBox(height: 3.h),
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
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryLight,
                        size: 20.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Filtered Results',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total',
                          filteredStats['total'].toString(),
                          Icons.school,
                          AppTheme.primaryLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Present',
                          filteredStats['present'].toString(),
                          Icons.check_circle,
                          AppTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Absent',
                          filteredStats['absent'].toString(),
                          Icons.cancel,
                          AppTheme.errorLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Late',
                          filteredStats['late'].toString(),
                          Icons.schedule,
                          AppTheme.warningLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 90) return AppTheme.successLight;
    if (percentage >= 75) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  bool _hasFiltersApplied() {
    return filteredStats['total'] != stats['total'];
  }
}
