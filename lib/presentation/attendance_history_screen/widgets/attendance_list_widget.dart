import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/attendance_model.dart';

class AttendanceListWidget extends StatelessWidget {
  final List<AttendanceModel> attendanceList;
  final bool showAll;

  const AttendanceListWidget({
    Key? key,
    required this.attendanceList,
    this.showAll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attendanceList.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 12.w,
                color: AppTheme.textSecondaryLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'No attendance records found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showAll ? 'All Records' : 'Recent Records',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                if (!showAll && attendanceList.length > 5)
                  TextButton(
                    onPressed: () {
                      // Navigate to full list
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: showAll ? attendanceList.length : attendanceList.length.clamp(0, 5),
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final attendance = attendanceList[index];
                return _buildAttendanceItem(context, attendance);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(BuildContext context, AttendanceModel attendance) {
    final isAccepted = attendance.result == AttendanceResult.accepted;
    final statusColor = isAccepted ? Colors.green : Colors.red;
    final statusIcon = isAccepted ? Icons.check_circle : Icons.cancel;
    final statusText = isAccepted ? 'Present' : 'Absent';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 5.w,
            ),
          ),
          
          SizedBox(width: 3.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Session: ${attendance.sessionId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                Text(
                  'Submitted: ${_formatDateTime(attendance.submittedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                if (attendance.reason != null)
                  Text(
                    'Reason: ${attendance.reason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          
          if (attendance.editedBy != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Edited',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}