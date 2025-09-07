import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AttendanceSubmissionWidget extends StatelessWidget {
  final bool isLoading;
  final bool isLocationVerified;
  final bool isCodeVerified;
  final VoidCallback onSubmit;

  const AttendanceSubmissionWidget({
    Key? key,
    required this.isLoading,
    required this.isLocationVerified,
    required this.isCodeVerified,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = isLocationVerified && isCodeVerified && !isLoading;

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
                  Icons.send,
                  color: canSubmit ? AppTheme.successLight : AppTheme.textSecondaryLight,
                  size: 24.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Submit Attendance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Requirements Checklist
            _buildRequirementItem(
              context,
              'Location Verified',
              isLocationVerified,
              Icons.location_on,
            ),
            
            SizedBox(height: 2.h),
            
            _buildRequirementItem(
              context,
              'Code Verified',
              isCodeVerified,
              Icons.vpn_key,
            ),
            
            SizedBox(height: 3.h),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: canSubmit ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSubmit 
                      ? AppTheme.primaryLight 
                      : AppTheme.textDisabledLight,
                  foregroundColor: Colors.white,
                  elevation: canSubmit ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Submitting...',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Mark Attendance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            if (!canSubmit && !isLoading) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.warningLight,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Please verify your location and attendance code before submitting.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String title,
    bool isCompleted,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.successLight.withOpacity(0.1)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.successLight.withOpacity(0.3)
              : AppTheme.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : icon,
            color: isCompleted ? AppTheme.successLight : AppTheme.textSecondaryLight,
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCompleted 
                    ? AppTheme.successLight 
                    : AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check,
              color: AppTheme.successLight,
              size: 16.sp,
            ),
        ],
      ),
    );
  }
}
