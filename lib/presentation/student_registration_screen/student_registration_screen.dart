import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_validation_service.dart';
import './widgets/hierarchical_dropdown_widget.dart';
import './widgets/profile_photo_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/terms_conditions_widget.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final LocationValidationService _locationService = LocationValidationService();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form state
  int _currentStep = 0;
  bool _isFormValid = false;
  bool _isHierarchyValid = false;
  bool _isTermsAccepted = false;
  bool _isRegistering = false;

  // Hierarchy selections
  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedBatch;

  // Profile photo
  XFile? _selectedPhoto;

  // Progress tracking
  double get _progressValue => (_currentStep + 1) / 4;

  final List<String> _stepTitles = [
    'Personal Information',
    'Academic Details',
    'Profile Setup',
    'Terms & Conditions',
  ];

  @override
  void initState() {
    super.initState();
    _setupHierarchyValidation();
  }

  void _setupHierarchyValidation() {
    // Listen for hierarchy changes to update validation
    setState(() {
      _isHierarchyValid = _selectedBranch != null &&
          _selectedClass != null &&
          _selectedBatch != null;
    });
  }

  void _onFormValidationChanged(bool isValid) {
    setState(() {
      _isFormValid = isValid;
    });
  }

  void _onHierarchyChanged() {
    setState(() {
      _isHierarchyValid = _selectedBranch != null &&
          _selectedClass != null &&
          _selectedBatch != null;
    });
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _isFormValid;
      case 1:
        return _isHierarchyValid;
      case 2:
        return true; // Profile photo is optional
      case 3:
        return _isTermsAccepted;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep() && _currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _registerStudent() async {
    if (!_canProceedToNextStep()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      // Validate location access before registration
      final locationResult = await _locationService.validateLocationAccess();
      if (!locationResult.isSuccess) {
        _showLocationErrorDialog(locationResult);
        return;
      }

      // Simulate registration process
      await Future.delayed(const Duration(seconds: 3));

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Registration failed. Please try again.');
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                size: 6.w,
                color: AppTheme.successLight,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Registration Successful!',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successLight,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your student account has been created successfully.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps:',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '1. Check your email for verification link\n'
                    '2. Verify your account to enable full access\n'
                    '3. Login to start marking attendance',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: Text('Continue to Login'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            SizedBox(width: 3.w),
            Text(
              'Registration Failed',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog(LocationValidationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.red,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Location Required',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.errorMessage ?? 'Location access is required to complete registration.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why is location required?',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• Secure attendance tracking\n• Prevent unauthorized access\n• Ensure student presence verification',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _locationService.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Open Settings',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 4',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(_progressValue * 100).toInt()}% Complete',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: _progressValue,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _stepTitles[_currentStep],
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return RegistrationFormWidget(
          formKey: _formKey,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          enrollmentController: _enrollmentController,
          nameController: _nameController,
          phoneController: _phoneController,
          onValidationChanged: _onFormValidationChanged,
        );
      case 1:
        return HierarchicalDropdownWidget(
          selectedBranch: _selectedBranch,
          selectedClass: _selectedClass,
          selectedBatch: _selectedBatch,
          onBranchChanged: (value) {
            setState(() {
              _selectedBranch = value;
            });
            _onHierarchyChanged();
          },
          onClassChanged: (value) {
            setState(() {
              _selectedClass = value;
            });
            _onHierarchyChanged();
          },
          onBatchChanged: (value) {
            setState(() {
              _selectedBatch = value;
            });
            _onHierarchyChanged();
          },
        );
      case 2:
        return ProfilePhotoWidget(
          selectedPhoto: _selectedPhoto,
          onPhotoSelected: (photo) {
            setState(() {
              _selectedPhoto = photo;
            });
          },
        );
      case 3:
        return TermsConditionsWidget(
          isAccepted: _isTermsAccepted,
          onChanged: (value) {
            setState(() {
              _isTermsAccepted = value;
            });
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'arrow_back',
                        size: 4.w,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Text('Previous'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _canProceedToNextStep()
                    ? (_currentStep == 3 ? _registerStudent : _nextStep)
                    : null,
                child: _isRegistering
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
                          Text(_currentStep == 3 ? 'Register' : 'Next'),
                          if (_currentStep < 3) ...[
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: 'arrow_forward',
                              size: 4.w,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Student Account'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: _buildStepContent(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: _buildStepContent(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: _buildStepContent(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _enrollmentController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
