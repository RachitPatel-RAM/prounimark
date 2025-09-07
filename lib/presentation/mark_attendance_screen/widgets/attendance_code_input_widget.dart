import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Attendance Code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                if (controller.text.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: isCodeVerified 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isCodeVerified ? Icons.check_circle : Icons.cancel,
                      color: isCodeVerified ? Colors.green : Colors.red,
                      size: 5.w,
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            Text(
              'Enter the 3-digit attendance code provided by your faculty',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 3,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '000',
                hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  letterSpacing: 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCodeVerified 
                        ? Colors.green
                        : controller.text.isNotEmpty 
                            ? Colors.red
                            : AppTheme.dividerLight,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isCodeVerified 
                        ? Colors.green
                        : controller.text.isNotEmpty 
                            ? Colors.red
                            : AppTheme.dividerLight,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryLight,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                counterText: '',
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppTheme.primaryLight,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? Icon(
                        isCodeVerified ? Icons.check : Icons.close,
                        color: isCodeVerified ? Colors.green : Colors.red,
                      )
                    : null,
              ),
              onChanged: onCodeChanged,
            ),
            
            SizedBox(height: 2.h),
            
            if (controller.text.isNotEmpty && !isCodeVerified)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Invalid attendance code. Please check with your faculty.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (isCodeVerified)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Attendance code verified successfully!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
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