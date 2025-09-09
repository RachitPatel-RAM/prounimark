import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/location_validation_service.dart';
import '../../services/hierarchy_service.dart';
import '../../services/biometric_service.dart';
import '../../models/hierarchy_model.dart';
import './widgets/flying_card_widget.dart';
import './widgets/pin_input_widget.dart';
import './widgets/biometric_setup_widget.dart';
import './widgets/hierarchical_dropdown_widget.dart';
import './widgets/registration_form_widget.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Services
  final AuthService _authService = AuthService();
  final LocationValidationService _locationService = LocationValidationService();
  final HierarchyService _hierarchyService = HierarchyService();
  final BiometricService _biometricService = BiometricService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _confirmEnrollmentController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form state
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isRegistering = false;

  // Hierarchy data
  List<BranchModel> _branches = [];
  List<ClassModel> _classes = [];
  List<BatchModel> _batches = [];

  // Hierarchy selections
  String? _selectedBranchId;
  String? _selectedClassId;
  String? _selectedBatchId;

  // Security setup
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _pin = '';
  String _confirmPin = '';
  Position? _currentLocation;

  // Progress tracking
  double get _progressValue => _currentStep / 4; // 0 to 1 for 5 steps (0-4)

  final List<String> _stepTitles = [
    'Personal Information',
    'Academic Details',
    'Location Access',
    'Security Setup',
    'Complete Registration',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _setupUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load branches
      final branches = await _hierarchyService.getBranches();
      
      // Check biometric availability
      final biometricAvailability = await _biometricService.checkBiometricAvailability();
      
      setState(() {
        _branches = branches;
        _biometricAvailable = biometricAvailability == BiometricAvailability.available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load registration data. Please try again.');
    }
  }

  void _setupUserData() {
    // Auto-fetch name from Google account
    final user = _authService.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
    
    // Add listeners to trigger form validation
    _nameController.addListener(_onFormChanged);
    _enrollmentController.addListener(_onFormChanged);
    _confirmEnrollmentController.addListener(_onFormChanged);
  }
  
  void _onFormChanged() {
    setState(() {
      // Trigger rebuild to update button state
    });
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty && 
               _enrollmentController.text.isNotEmpty &&
               _confirmEnrollmentController.text.isNotEmpty &&
               _enrollmentController.text == _confirmEnrollmentController.text;
      case 1:
        return _selectedBranchId != null && 
               _selectedClassId != null && 
               _selectedBatchId != null;
      case 2:
        return _currentLocation != null;
      case 3:
        return _biometricEnabled || (_pin.length == 4 && _pin == _confirmPin);
      case 4:
        return true; // Final step
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep() && _currentStep < 4) {
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

  Future<void> _onBranchChanged(String? branchId) async {
    setState(() {
      _selectedBranchId = branchId;
      _selectedClassId = null;
      _selectedBatchId = null;
      _classes = [];
      _batches = [];
    });

    if (branchId != null) {
      final classes = await _hierarchyService.getClassesByBranch(branchId);
      setState(() {
        _classes = classes;
      });
    }
  }

  Future<void> _onClassChanged(String? classId) async {
    setState(() {
      _selectedClassId = classId;
      _selectedBatchId = null;
      _batches = [];
    });

    if (classId != null) {
      final batches = await _hierarchyService.getBatchesByClass(classId);
      setState(() {
        _batches = batches;
      });
    }
  }

  void _onBatchChanged(String? batchId) {
    setState(() {
      _selectedBatchId = batchId;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationResult = await _locationService.validateLocationAccess();
      if (locationResult.isSuccess) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        setState(() {
          _currentLocation = position;
        });
      } else {
        _showLocationErrorDialog(locationResult);
      }
    } catch (e) {
      _showErrorDialog('Failed to get location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onBiometricToggle(bool enabled) {
    setState(() {
      _biometricEnabled = enabled;
      if (enabled) {
        _pin = '';
        _confirmPin = '';
      }
    });
  }

  void _onPinChanged(String pin) {
    setState(() {
      _pin = pin;
    });
  }

  void _onConfirmPinChanged(String confirmPin) {
    setState(() {
      _confirmPin = confirmPin;
    });
  }

  Future<void> _registerStudent() async {
    if (!_canProceedToNextStep()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      // Complete student registration
      final result = await _authService.completeStudentRegistration(
        enrollmentNo: _enrollmentController.text,
        branchId: _selectedBranchId!,
        classId: _selectedClassId!,
        batchId: _selectedBatchId!,
        pin: _biometricEnabled ? null : _pin,
        biometricEnabled: _biometricEnabled,
      );

      if (result.isSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result.error ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Registration failed: $e');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
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
              'Your student account has been created successfully. You can now mark attendance for your classes.',
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
                    'Security Features Enabled:',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• Device binding for secure access\n'
                    '• ${_biometricEnabled ? 'Biometric authentication' : 'PIN protection'}\n'
                    '• Location-based attendance verification\n'
                    '• Anti-proxy security measures',
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
                Navigator.pushReplacementNamed(context, '/student-dashboard');
              },
              child: Text('Go to Dashboard'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error,
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
                'Step ${_currentStep + 1} of 5',
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
        return FlyingCardWidget(
          child: RegistrationFormWidget(
            formKey: _formKey,
            nameController: _nameController,
            enrollmentController: _enrollmentController,
            confirmEnrollmentController: _confirmEnrollmentController,
          ),
        );
      case 1:
        return FlyingCardWidget(
          child: HierarchicalDropdownWidget(
            branches: _branches,
            classes: _classes,
            batches: _batches,
            selectedBranchId: _selectedBranchId,
            selectedClassId: _selectedClassId,
            selectedBatchId: _selectedBatchId,
            onBranchChanged: _onBranchChanged,
            onClassChanged: _onClassChanged,
            onBatchChanged: _onBatchChanged,
          ),
        );
      case 2:
        return FlyingCardWidget(
          child: _buildLocationStep(),
        );
      case 3:
        return FlyingCardWidget(
          child: _buildSecurityStep(),
        );
      case 4:
        return FlyingCardWidget(
          child: _buildFinalStep(),
        );
      default:
        return Container();
    }
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Location Access',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'We need access to your location to ensure secure attendance tracking. This helps prevent unauthorized access and ensures you are physically present.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        if (_currentLocation != null) ...[
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successLight,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Captured',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}\nLng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: _isLoading
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(Icons.my_location),
              label: Text(_isLoading ? 'Getting Location...' : 'Get Current Location'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.security,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Security Setup',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Choose your preferred security method for attendance verification.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        if (_biometricAvailable) ...[
          BiometricSetupWidget(
            isEnabled: _biometricEnabled,
            onToggle: _onBiometricToggle,
          ),
          SizedBox(height: 3.h),
        ],
        if (!_biometricEnabled) ...[
          Text(
            'Set up a 4-digit PIN for secure access:',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          PinInputWidget(
            label: 'Enter PIN',
            onChanged: _onPinChanged,
          ),
          SizedBox(height: 2.h),
          PinInputWidget(
            label: 'Confirm PIN',
            onChanged: _onConfirmPinChanged,
          ),
          if (_pin.isNotEmpty && _confirmPin.isNotEmpty && _pin != _confirmPin) ...[
            SizedBox(height: 1.h),
            Text(
              'PINs do not match',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Review & Complete',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'Please review your information before completing registration:',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewItem('Name', _nameController.text),
              _buildReviewItem('Enrollment', _enrollmentController.text),
              _buildReviewItem('Branch', _branches.firstWhere((b) => b.id == _selectedBranchId).name),
              _buildReviewItem('Class', _classes.firstWhere((c) => c.id == _selectedClassId).name),
              _buildReviewItem('Batch', _batches.firstWhere((b) => b.id == _selectedBatchId).name),
              _buildReviewItem('Security', _biometricEnabled ? 'Biometric' : 'PIN'),
              _buildReviewItem('Location', 'Captured'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
                      Icon(
                        Icons.arrow_back,
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
                    ? (_currentStep == 4 ? _registerStudent : _nextStep)
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
                          Text(_currentStep == 4 ? 'Complete Registration' : 'Next'),
                          if (_currentStep < 4) ...[
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.arrow_forward,
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
        title: Text('Student Registration'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading && _branches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading registration data...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildProgressIndicator(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(5, (index) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.all(4.w),
                            child: _buildStepContent(),
                          );
                        }),
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _enrollmentController.dispose();
    _confirmEnrollmentController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
