import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptySessionsWidget extends StatelessWidget {
  const EmptySessionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
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
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CustomIconWidget(
              iconName: 'event_busy',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No Active Sessions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'There are no attendance sessions available at the moment. Check back later or contact your faculty.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          OutlinedButton.icon(
            onPressed: () {
              // Refresh functionality
            },
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            label: Text(
              'Refresh',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: AppTheme.lightTheme.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
