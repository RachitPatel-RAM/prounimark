import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/location_validation_service.dart';
import '../../models/user_model.dart';
import 'widgets/login_button_widget.dart';
import 'widgets/login_form_widget.dart';
import 'widgets/role_selector_widget.dart';
import 'widgets/university_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Services
  final AuthService _authService = AuthService();
  final LocationValidationService _locationService = LocationValidationService();
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminUsernameController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  // State variables
  String _selectedRole = 'Student';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Error states
  String? _emailError;
  String? _passwordError;
  String? _adminUsernameError;
  String? _adminPasswordError;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Admin credentials (static)
  final Map<String, String> _adminCredentials = {
    'username': 'ADMIN',
    'password': 'ADMIN9090',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _addTextFieldListeners();
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

  void _addTextFieldListeners() {
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _adminUsernameController.addListener(_validateForm);
    _adminPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      if (_selectedRole == 'Admin') {
        _adminUsernameError =
            _validateAdminUsername(_adminUsernameController.text);
        _adminPasswordError =
            _validateAdminPassword(_adminPasswordController.text);
      } else {
        _emailError = _validateEmail(_emailController.text);
        _passwordError = _validatePassword(_passwordController.text);
      }
    });
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return null;

    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }

    if (_selectedRole == 'Student' && !email.endsWith('@darshan.ac.in')) {
      return 'Student email must be from @darshan.ac.in domain';
    }

    if (_selectedRole == 'Faculty' && !email.endsWith('@darshan.ac.in')) {
      return 'Faculty email must be from @darshan.ac.in domain';
    }

    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return null;

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  String? _validateAdminUsername(String username) {
    if (username.isEmpty) return null;

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    return null;
  }

  String? _validateAdminPassword(String password) {
    if (password.isEmpty) return null;

    if (password.length < 8) {
      return 'Admin password must be at least 8 characters long';
    }

    return null;
  }

  bool get _isFormValid {
    if (_selectedRole == 'Admin') {
      return _adminUsernameController.text.isNotEmpty &&
          _adminPasswordController.text.isNotEmpty &&
          _adminUsernameError == null &&
          _adminPasswordError == null;
    } else if (_selectedRole == 'Student') {
      // Students use Google Sign-In, so form is always valid
      return true;
    } else {
      return _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _emailError == null &&
          _passwordError == null;
    }
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      _clearErrors();
    });

    // Clear controllers when switching roles
    if (role == 'Admin') {
      _emailController.clear();
      _passwordController.clear();
    } else {
      _adminUsernameController.clear();
      _adminPasswordController.clear();
    }
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _adminUsernameError = null;
      _adminPasswordError = null;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // For students and faculty, validate location access first
      if (_selectedRole == 'Student' || _selectedRole == 'Faculty') {
        final locationResult = await _locationService.validateLocationAccess();
        if (!locationResult.isSuccess) {
          setState(() {
            _isLoading = false;
          });
          
          // Show location error dialog
          _showLocationErrorDialog(locationResult);
          return;
        }
      }

      AuthResult result;
      
      if (_selectedRole == 'Admin') {
        // Admin login with static credentials
        result = await _authService.adminLogin(
          _adminUsernameController.text,
          _adminPasswordController.text,
        );
      } else if (_selectedRole == 'Student') {
        // Student login with Google SSO
        result = await _authService.signInWithGoogle();
      } else if (_selectedRole == 'Faculty') {
        // Faculty login with email/password
        result = await _authService.signInFacultyWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Default fallback
        result = AuthResult.failure('Invalid role selected');
      }

      if (result.isSuccess && result.user != null) {
        // Success haptic feedback
        HapticFeedback.heavyImpact();

        // Navigate to appropriate dashboard
        String route;
        switch (result.user!.role) {
          case UserRole.student:
            route = '/student-dashboard';
            break;
          case UserRole.faculty:
            // Check if faculty needs to change password
            if (result.user!.tempPassword == true) {
              route = '/faculty-password-reset';
            } else {
              route = '/faculty-dashboard';
            }
            break;
          case UserRole.admin:
            route = '/admin-dashboard';
            break;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, route);
        }
      } else if (result.needsRegistration) {
        // Student needs to complete registration
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/student-registration-screen');
        }
      } else {
        // Error haptic feedback
        HapticFeedback.heavyImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Login failed. Please try again.'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              result.errorMessage ?? 'Location access is required to use this application.',
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 6.h),

                    // University Logo
                    const UniversityLogoWidget(),

                    SizedBox(height: 4.h),

                    // Welcome Text
                    Text(
                      'Welcome to UniMark',
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Secure attendance management system',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    // Login Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.shadow
                                .withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Selector
                          Text(
                            'Select Role',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          RoleSelectorWidget(
                            selectedRole: _selectedRole,
                            onRoleChanged: _onRoleChanged,
                          ),

                          SizedBox(height: 4.h),

                          // Login Form
                          LoginFormWidget(
                            selectedRole: _selectedRole,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            adminUsernameController: _adminUsernameController,
                            adminPasswordController: _adminPasswordController,
                            isPasswordVisible: _isPasswordVisible,
                            onTogglePasswordVisibility:
                                _togglePasswordVisibility,
                            emailError: _emailError,
                            passwordError: _passwordError,
                            adminUsernameError: _adminUsernameError,
                            adminPasswordError: _adminPasswordError,
                          ),

                          SizedBox(height: 4.h),

                          // Login Button
                          LoginButtonWidget(
                            isLoading: _isLoading,
                            isFormValid: _isFormValid,
                            onPressed: _handleLogin,
                            selectedRole: _selectedRole,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Registration Link for Students
                    if (_selectedRole == 'Student') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/student-registration-screen');
                            },
                            child: Text(
                              'Register here',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 2.h),

                    // Demo Credentials Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Demo Credentials',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _selectedRole == 'Admin'
                                ? 'Username: ${_adminCredentials['username']}\nPassword: ${_adminCredentials['password']}'
                                : _selectedRole == 'Student'
                                    ? 'Use Google Sign-In with @darshan.ac.in email'
                                    : 'Use Google Sign-In with @darshan.ac.in email\n(Faculty role required)',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}