import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const AttendanceSummaryWidget({
    super.key,
    required this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    final todaySessions = summaryData['todaySessions'] ?? 0;
    final totalStudents = summaryData['totalStudents'] ?? 0;
    final averageAttendance = summaryData['averageAttendance'] ?? 0.0;
    final activeSessions = summaryData['activeSessions'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                AppTheme.lightTheme.colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(),
              SizedBox(height: 3.h),
              _buildSummaryGrid(todaySessions, totalStudents, averageAttendance,
                  activeSessions),
              SizedBox(height: 2.h),
              _buildAttendanceTrend(averageAttendance),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'analytics',
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Summary',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Today\'s overview',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.getSuccessColor(true).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Live',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.getSuccessColor(true),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(int todaySessions, int totalStudents,
      double averageAttendance, int activeSessions) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: 'event_note',
            title: 'Today\'s Sessions',
            value: todaySessions.toString(),
            color: AppTheme.lightTheme.colorScheme.primary,
            subtitle:
                activeSessions > 0 ? '$activeSessions active' : 'All completed',
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildSummaryCard(
            icon: 'group',
            title: 'Total Students',
            value: totalStudents.toString(),
            color: AppTheme.lightTheme.colorScheme.tertiary,
            subtitle: 'Enrolled',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
              Spacer(),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTrend(double averageAttendance) {
    final attendancePercentage = averageAttendance / 100;
    final trendColor = averageAttendance >= 75
        ? AppTheme.getSuccessColor(true)
        : averageAttendance >= 50
            ? AppTheme.getWarningColor(true)
            : AppTheme.getErrorColor(true);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average Attendance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: averageAttendance >= 75
                        ? 'trending_up'
                        : averageAttendance >= 50
                            ? 'trending_flat'
                            : 'trending_down',
                    color: trendColor,
                    size: 20,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${averageAttendance.toStringAsFixed(1)}%',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: attendancePercentage,
            backgroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(trendColor),
            minHeight: 1.h,
          ),
          SizedBox(height: 1.h),
          Text(
            _getAttendanceFeedback(averageAttendance),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getAttendanceFeedback(double attendance) {
    if (attendance >= 90) {
      return 'Excellent attendance rate! Students are highly engaged.';
    } else if (attendance >= 75) {
      return 'Good attendance rate. Keep up the great work!';
    } else if (attendance >= 60) {
      return 'Moderate attendance. Consider engagement strategies.';
    } else if (attendance >= 40) {
      return 'Low attendance. May need intervention.';
    } else {
      return 'Very low attendance. Immediate attention required.';
    }
  }
}
