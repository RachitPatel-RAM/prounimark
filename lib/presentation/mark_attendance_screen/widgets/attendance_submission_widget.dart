import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AttendanceSubmissionWidget extends StatelessWidget {
  final bool isLoading;
  final bool isLocationVerified;
  final bool isCodeVerified;
  final VoidCallback onSubmit;

  const AttendanceSubmissionWidget({
    super.key,
    required this.isLoading,
    required this.isLocationVerified,
    required this.isCodeVerified,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final canSubmit = isLocationVerified && isCodeVerified && !isLoading;
    
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
            Text(
              'Submit Attendance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Verification Checklist
            _buildChecklistItem(
              context,
              'Location Verified',
              isLocationVerified,
              'Your location is within the required radius',
            ),
            
            SizedBox(height: 2.h),
            
            _buildChecklistItem(
              context,
              'Code Verified',
              isCodeVerified,
              'Attendance code is correct',
            ),
            
            SizedBox(height: 3.h),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton.icon(
                onPressed: canSubmit ? onSubmit : null,
                icon: isLoading 
                    ? SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading 
                      ? 'Submitting...'
                      : 'Mark Attendance',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSubmit 
                      ? AppTheme.primaryLight
                      : AppTheme.textSecondaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canSubmit ? 4 : 0,
                ),
              ),
            ),
            
            if (!canSubmit && !isLoading)
              SizedBox(height: 2.h),
            
            if (!canSubmit && !isLoading)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Color.fromRGBO((AppTheme.warningLight.r * 255.0).round() & 0xff, (AppTheme.warningLight.g * 255.0).round() & 0xff, (AppTheme.warningLight.b * 255.0).round() & 0xff, 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color.fromRGBO((AppTheme.warningLight.r * 255.0).round() & 0xff, (AppTheme.warningLight.g * 255.0).round() & 0xff, (AppTheme.warningLight.b * 255.0).round() & 0xff, 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.warningLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Please verify your location and attendance code before submitting.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warningLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    String title,
    bool isVerified,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isVerified 
            ? const Color.fromRGBO(0, 255, 0, 0.1)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified 
              ? const Color.fromRGBO(0, 255, 0, 0.3)
              : AppTheme.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : AppTheme.textSecondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.check : Icons.close,
              color: Colors.white,
              size: 4.w,
            ),
          ),
          
          SizedBox(width: 3.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isVerified ? Colors.green : AppTheme.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}