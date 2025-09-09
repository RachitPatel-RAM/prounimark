import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginButtonWidget extends StatelessWidget {
  final bool isLoading;
  final bool isFormValid;
  final VoidCallback onPressed;
  final String selectedRole;

  const LoginButtonWidget({
    super.key,
    required this.isLoading,
    required this.isFormValid,
    required this.onPressed,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isFormValid && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.12),
          foregroundColor: isFormValid
              ? AppTheme.lightTheme.colorScheme.onPrimary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.38),
          elevation: isFormValid ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'login',
                    color: isFormValid
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.38),
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    selectedRole == 'Student' ? 'Sign in with Google' : 'Login',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: isFormValid
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.38),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
