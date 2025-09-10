import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/secure_text_field.dart';

class RegistrationFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController enrollmentController;
  final TextEditingController confirmEnrollmentController;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.enrollmentController,
    required this.confirmEnrollmentController,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  bool _isNameValid = false;
  bool _isEnrollmentValid = false;
  bool _isConfirmEnrollmentValid = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    widget.nameController.addListener(_validateName);
    widget.enrollmentController.addListener(_validateEnrollment);
    widget.confirmEnrollmentController.addListener(_validateConfirmEnrollment);
  }

  void _validateName() {
    setState(() {
      _isNameValid = widget.nameController.text.trim().isNotEmpty;
    });
  }

  void _validateEnrollment() {
    setState(() {
      final text = widget.enrollmentController.text.trim();
      _isEnrollmentValid = text.isNotEmpty && 
          RegExp(r'^[A-Za-z0-9]+$').hasMatch(text) &&
          text.length >= 6;
    });
  }

  void _validateConfirmEnrollment() {
    setState(() {
      final enrollment = widget.enrollmentController.text.trim();
      final confirm = widget.confirmEnrollmentController.text.trim();
      _isConfirmEnrollmentValid = confirm.isNotEmpty && 
          enrollment == confirm;
    });
  }

  String? _validateNameField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEnrollmentField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enrollment number is required';
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
      return 'Enrollment number can only contain letters and numbers';
    }
    if (value.trim().length < 6) {
      return 'Enrollment number must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmEnrollmentField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your enrollment number';
    }
    if (value.trim() != widget.enrollmentController.text.trim()) {
      return 'Enrollment numbers do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Personal Information',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Please provide your personal details. Your name will be auto-filled from your Google account but you can edit it if needed.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          
          // Name Field
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(
                Icons.person_outline,
                color: _isNameValid
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _isNameValid
                  ? Icon(
                      Icons.check_circle,
                      color: AppTheme.successLight,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
            validator: _validateNameField,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 3.h),

          // Enrollment Number Field
          SecureTextField(
            controller: widget.enrollmentController,
            labelText: 'Enrollment Number',
            hintText: 'Enter your enrollment number',
            prefixIcon: Icons.badge_outlined,
            validator: _validateEnrollmentField,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            showSuffixIcon: true,
            suffixIconColor: AppTheme.successLight,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
          ),
          SizedBox(height: 3.h),

          // Confirm Enrollment Number Field
          SecureTextField(
            controller: widget.confirmEnrollmentController,
            labelText: 'Confirm Enrollment Number',
            hintText: 'Re-enter your enrollment number',
            prefixIcon: Icons.verified_user_outlined,
            validator: _validateConfirmEnrollmentField,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            showSuffixIcon: true,
            suffixIconColor: AppTheme.successLight,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
          ),
          SizedBox(height: 2.h),

          // Info Card
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Important Notes',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Your enrollment number must be unique and will be verified\n'
                  '• Copy-paste is disabled for security reasons\n'
                  '• Please double-check your enrollment number before proceeding',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
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