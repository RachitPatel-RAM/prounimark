import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final String selectedRole;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController adminUsernameController;
  final TextEditingController adminPasswordController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final String? emailError;
  final String? passwordError;
  final String? adminUsernameError;
  final String? adminPasswordError;

  const LoginFormWidget({
    Key? key,
    required this.selectedRole,
    required this.emailController,
    required this.passwordController,
    required this.adminUsernameController,
    required this.adminPasswordController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
    this.emailError,
    this.passwordError,
    this.adminUsernameError,
    this.adminPasswordError,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.selectedRole == 'Admin') ...[
          _buildAdminUsernameField(),
          SizedBox(height: 3.h),
          _buildAdminPasswordField(),
        ] else ...[
          _buildEmailField(),
          SizedBox(height: 3.h),
          _buildPasswordField(),
        ],
        if (widget.selectedRole != 'Admin') ...[
          SizedBox(height: 2.h),
          _buildForgotPasswordLink(),
        ],
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: widget.selectedRole == 'Student'
                ? 'student@darshan.ac.in'
                : 'faculty@darshan.ac.in',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: widget.emailError,
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.passwordController,
          obscureText: !widget.isPasswordVisible,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: widget.onTogglePasswordVisibility,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: widget.isPasswordVisible
                      ? 'visibility'
                      : 'visibility_off',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            errorText: widget.passwordError,
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildAdminUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.adminUsernameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Admin Username',
            hintText: 'Enter admin username',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'admin_panel_settings',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            errorText: widget.adminUsernameError,
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildAdminPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.adminPasswordController,
          obscureText: !widget.isPasswordVisible,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Admin Password',
            hintText: 'Enter admin password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: widget.onTogglePasswordVisibility,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: widget.isPasswordVisible
                      ? 'visibility'
                      : 'visibility_off',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            errorText: widget.adminPasswordError,
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // Handle forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Password reset email will be sent to your registered email'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        },
        child: Text(
          'Forgot Password?',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
