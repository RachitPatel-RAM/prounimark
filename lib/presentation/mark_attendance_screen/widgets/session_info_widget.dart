import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/session_model.dart';

class SessionInfoWidget extends StatelessWidget {
  final SessionModel session;

  const SessionInfoWidget({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Icons.school,
                  color: AppTheme.primaryLight,
                  size: 24.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Session Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: session.isActive 
                        ? AppTheme.successLight.withOpacity(0.1)
                        : AppTheme.errorLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.isActive ? 'Active' : 'Ended',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: session.isActive 
                          ? AppTheme.successLight
                          : AppTheme.errorLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            _buildInfoRow(
              context,
              Icons.person,
              'Faculty',
              session.facultyName,
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.book,
              'Subject',
              session.subject,
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.location_on,
              'Branch',
              session.branch,
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.class_,
              'Class',
              session.className,
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.group,
              'Batches',
              session.batches.join(', '),
            ),
            
            SizedBox(height: 2.h),
            
            _buildInfoRow(
              context,
              Icons.access_time,
              'Started',
              _formatDateTime(session.startTime),
            ),
            
            if (session.endTime != null) ...[
              SizedBox(height: 2.h),
              _buildInfoRow(
                context,
                Icons.access_time_filled,
                'Ended',
                _formatDateTime(session.endTime!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondaryLight,
          size: 18.sp,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
