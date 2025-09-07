import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'No attendance records found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your attendance history will appear here once you start attending classes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = attendanceList[index];
        return _buildAttendanceCard(context, attendance);
      },
    );
  }

  Widget _buildAttendanceCard(BuildContext context, AttendanceModel attendance) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and date
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(attendance.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(attendance.status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(attendance.status),
                        color: _getStatusColor(attendance.status),
                        size: 16.sp,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _getStatusText(attendance.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(attendance.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(attendance.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Time and details
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppTheme.textSecondaryLight,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  DateFormat('hh:mm a').format(attendance.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (attendance.isEdited) ...[
                  Icon(
                    Icons.edit,
                    color: AppTheme.warningLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Edited',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            
            if (attendance.location != null) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppTheme.textSecondaryLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Location: ${attendance.location!.latitude.toStringAsFixed(4)}, ${attendance.location!.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    color: AppTheme.textSecondaryLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      attendance.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (attendance.editedBy != null) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppTheme.textSecondaryLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Edited by: ${attendance.editedBy}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.successLight;
      case AttendanceStatus.absent:
        return AppTheme.errorLight;
      case AttendanceStatus.late:
        return AppTheme.warningLight;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
}
