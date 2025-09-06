import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/login_button_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/role_selector_widget.dart';
import './widgets/university_logo_widget.dart';
import 'widgets/login_button_widget.dart';
import 'widgets/login_form_widget.dart';
import 'widgets/role_selector_widget.dart';
import 'widgets/university_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
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

  // Mock credentials for demonstration
  final Map<String, Map<String, String>> _mockCredentials = {
    'Admin': {
      'username': 'ADMIN404',
      'password': 'ADMIN9090@@@@',
    },
    'Student': {
      'email': 'student@darshan.ac.in',
      'password': 'Student123!',
    },
    'Faculty': {
      'email': 'faculty@darshan.ac.in',
      'password': 'Faculty123!',
    },
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
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 2));

      bool isAuthenticated = false;
      String errorMessage = '';

      if (_selectedRole == 'Admin') {
        final mockAdmin = _mockCredentials['Admin']!;
        if (_adminUsernameController.text == mockAdmin['username'] &&
            _adminPasswordController.text == mockAdmin['password']) {
          isAuthenticated = true;
        } else {
          errorMessage =
              'Invalid admin credentials. Please check username and password.';
        }
      } else {
        final mockUser = _mockCredentials[_selectedRole]!;
        if (_emailController.text == mockUser['email'] &&
            _passwordController.text == mockUser['password']) {
          isAuthenticated = true;
        } else {
          errorMessage =
              'Invalid credentials. Please check email and password.';
        }
      }

      if (isAuthenticated) {
        // Success haptic feedback
        HapticFeedback.heavyImpact();

        // Navigate to appropriate dashboard
        String route;
        switch (_selectedRole) {
          case 'Student':
            route = '/student-dashboard';
            break;
          case 'Faculty':
            route = '/faculty-dashboard';
            break;
          case 'Admin':
            route =
                '/faculty-dashboard'; // Admin uses faculty dashboard for now
            break;
          default:
            route = '/student-dashboard';
        }

        Navigator.pushReplacementNamed(context, route);
      } else {
        // Error haptic feedback
        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                                ? 'Username: ${_mockCredentials['Admin']!['username']}\nPassword: ${_mockCredentials['Admin']!['password']}'
                                : 'Email: ${_mockCredentials[_selectedRole]!['email']}\nPassword: ${_mockCredentials[_selectedRole]!['password']}',
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