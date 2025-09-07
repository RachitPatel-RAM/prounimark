import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class AttendanceCodeInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isCodeVerified;
  final Function(String) onCodeChanged;

  const AttendanceCodeInputWidget({
    Key? key,
    required this.controller,
    required this.isCodeVerified,
    required this.onCodeChanged,
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
                  Icons.vpn_key,
                  color: isCodeVerified ? AppTheme.successLight : AppTheme.primaryLight,
                  size: 24.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Attendance Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                if (isCodeVerified)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successLight,
                    size: 24.sp,
                  ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            Text(
              'Enter the 3-digit attendance code provided by your faculty:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '000',
                hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: AppTheme.textDisabledLight,
                  letterSpacing: 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCodeVerified 
                        ? AppTheme.successLight 
                        : AppTheme.dividerLight,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCodeVerified 
                        ? AppTheme.successLight 
                        : AppTheme.dividerLight,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCodeVerified 
                        ? AppTheme.successLight 
                        : AppTheme.primaryLight,
                    width: 3,
                  ),
                ),
                filled: true,
                fillColor: isCodeVerified 
                    ? AppTheme.successLight.withOpacity(0.05)
                    : AppTheme.backgroundLight,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.h,
                ),
                suffixIcon: isCodeVerified
                    ? Icon(
                        Icons.check_circle,
                        color: AppTheme.successLight,
                        size: 24.sp,
                      )
                    : null,
              ),
              onChanged: onCodeChanged,
            ),
            
            SizedBox(height: 2.h),
            
            if (isCodeVerified) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successLight,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Code verified successfully!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (controller.text.isNotEmpty && !isCodeVerified) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: AppTheme.errorLight,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Invalid code. Please check with your faculty.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 2.h),
            
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.dividerLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryLight,
                    size: 18.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'The attendance code is displayed on the faculty\'s device during the session.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
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
}
