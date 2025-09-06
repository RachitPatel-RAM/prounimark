import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UpcomingClassCard extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback? onCreateSession;

  const UpcomingClassCard({
    Key? key,
    required this.classData,
    this.onCreateSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectName = classData['subjectName'] ?? 'Unknown Subject';
    final className = classData['className'] ?? 'Unknown Class';
    final batchName = classData['batchName'] ?? 'Unknown Batch';
    final startTime = classData['startTime'] ?? '00:00';
    final endTime = classData['endTime'] ?? '00:00';
    final room = classData['room'] ?? 'TBA';
    final studentCount = classData['studentCount'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassHeader(subjectName, className, batchName),
              SizedBox(height: 2.h),
              _buildClassDetails(startTime, endTime, room, studentCount),
              SizedBox(height: 2.h),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassHeader(
      String subjectName, String className, String batchName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'school',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '$className • $batchName',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppTheme.getWarningColor(true).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.getWarningColor(true).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Upcoming',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.getWarningColor(true),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassDetails(
      String startTime, String endTime, String room, int studentCount) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: 'schedule',
                  label: 'Time',
                  value: '$startTime - $endTime',
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildDetailItem(
                  icon: 'location_on',
                  label: 'Room',
                  value: room,
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildDetailItem(
            icon: 'group',
            label: 'Students',
            value: '$studentCount students enrolled',
            color: AppTheme.lightTheme.colorScheme.secondary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 18,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onCreateSession,
        icon: CustomIconWidget(
          iconName: 'add_circle_outline',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        label: Text(
          'Create Attendance Session',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
