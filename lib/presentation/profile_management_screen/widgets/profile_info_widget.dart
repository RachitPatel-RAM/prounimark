import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/user_model.dart';

class ProfileInfoWidget extends StatelessWidget {
  final UserModel user;

  const ProfileInfoWidget({
    Key? key,
    required this.user,
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
            // Section Title
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Information Items
            _buildInfoItem(
              context,
              'Email',
              user.email,
              Icons.email_outlined,
            ),
            
            if (user.enrollmentNo != null || user.enrollmentNumber != null)
              _buildInfoItem(
                context,
                'Enrollment Number',
                user.enrollmentNo ?? user.enrollmentNumber ?? '',
                Icons.badge_outlined,
              ),
            
            if (user.branch != null)
              _buildInfoItem(
                context,
                'Branch',
                user.branch!,
                Icons.school_outlined,
              ),
            
            if (user.classId != null || user.className != null)
              _buildInfoItem(
                context,
                'Class',
                user.className ?? user.classId ?? '',
                Icons.class_outlined,
              ),
            
            if (user.batchId != null || user.batch != null)
              _buildInfoItem(
                context,
                'Batch',
                user.batch ?? user.batchId ?? '',
                Icons.groups_outlined,
              ),
            
            _buildInfoItem(
              context,
              'Account Status',
              user.isActive ? 'Active' : 'Inactive',
              Icons.verified_user_outlined,
              valueColor: user.isActive ? Colors.green : Colors.red,
            ),
            
            _buildInfoItem(
              context,
              'Member Since',
              _formatDate(user.createdAt),
              Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryLight,
              size: 5.w,
            ),
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
                    color: valueColor ?? AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
