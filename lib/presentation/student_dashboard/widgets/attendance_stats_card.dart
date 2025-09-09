import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceStatsCard extends StatelessWidget {
  final double attendancePercentage;
  final int presentDays;
  final int absentDays;
  final int totalDays;

  const AttendanceStatsCard({
    super.key,
    required this.attendancePercentage,
    required this.presentDays,
    required this.absentDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Attendance Overview',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                value: attendancePercentage / 100,
                                strokeWidth: 8,
                                backgroundColor: AppTheme
                                    .lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  attendancePercentage >= 75
                                      ? AppTheme.getSuccessColor(true)
                                      : attendancePercentage >= 60
                                          ? AppTheme.getWarningColor(true)
                                          : AppTheme.getErrorColor(true),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${attendancePercentage.toInt()}%',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: attendancePercentage >= 75
                                        ? AppTheme.getSuccessColor(true)
                                        : attendancePercentage >= 60
                                            ? AppTheme.getWarningColor(true)
                                            : AppTheme.getErrorColor(true),
                                  ),
                                ),
                                Text(
                                  'Overall',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
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
              SizedBox(width: 4.w),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildStatRow(
                      'Present Days',
                      presentDays.toString(),
                      AppTheme.getSuccessColor(true),
                      'check_circle',
                    ),
                    SizedBox(height: 2.h),
                    _buildStatRow(
                      'Absent Days',
                      absentDays.toString(),
                      AppTheme.getErrorColor(true),
                      'cancel',
                    ),
                    SizedBox(height: 2.h),
                    _buildStatRow(
                      'Total Days',
                      totalDays.toString(),
                      AppTheme.lightTheme.colorScheme.onSurface,
                      'calendar_today',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, Color color, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
