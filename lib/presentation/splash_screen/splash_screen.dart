import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _gradientAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _gradientAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Gradient animation controller
    _gradientAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Gradient animation
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _gradientAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Simulate initialization steps
      await _performInitializationSteps();

      // Navigate based on authentication status
      await _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<void> _performInitializationSteps() async {
    final List<Map<String, dynamic>> initSteps = [
      {'message': 'Checking authentication...', 'duration': 800},
      {'message': 'Loading preferences...', 'duration': 600},
      {'message': 'Validating device...', 'duration': 700},
      {'message': 'Preparing data...', 'duration': 500},
    ];

    for (final step in initSteps) {
      if (mounted) {
        setState(() {
          _initializationStatus = step['message'] as String;
        });
      }
      await Future.delayed(Duration(milliseconds: step['duration'] as int));
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Simulate authentication check
    final bool isAuthenticated = await _checkAuthenticationStatus();
    final String? userRole = await _getUserRole();

    // Determine navigation route
    String nextRoute;
    if (isAuthenticated && userRole != null) {
      switch (userRole.toLowerCase()) {
        case 'student':
          nextRoute = '/student-dashboard';
          break;
        case 'faculty':
          nextRoute = '/faculty-dashboard';
          break;
        case 'admin':
          nextRoute = '/admin-dashboard';
          break;
        default:
          nextRoute = '/login-screen';
      }
    } else {
      // Check if user needs registration
      final bool needsRegistration = await _checkRegistrationStatus();
      nextRoute =
          needsRegistration ? '/student-registration-screen' : '/login-screen';
    }

    // Smooth transition with fade effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate Firebase auth check
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock authentication status - in real app, check Firebase Auth
    return false; // Default to not authenticated for demo
  }

  Future<String?> _getUserRole() async {
    // Simulate user role retrieval
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock user role - in real app, get from Firestore user document
    return null;
  }

  Future<bool> _checkRegistrationStatus() async {
    // Simulate registration status check
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock registration status - in real app, check local storage or user preferences
    return false; // Default to existing user
  }

  void _handleInitializationError(dynamic error) {
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _initializationStatus = 'Initialization failed';
      });

      // Show retry option after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _showRetryDialog();
        }
      });
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Connection Error',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Unable to initialize the app. Please check your internet connection and try again.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isInitializing = true;
                  _initializationStatus = 'Retrying...';
                });
                _initializeApp();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoAnimationController,
          _gradientAnimationController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryLight.withValues(
                    alpha: 0.9 + (0.1 * _gradientAnimation.value),
                  ),
                  AppTheme.secondaryLight.withValues(
                    alpha: 0.8 + (0.2 * _gradientAnimation.value),
                  ),
                ],
                stops: [
                  0.3 - (0.1 * _gradientAnimation.value),
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content to center
                  const Spacer(flex: 2),

                  // Logo section
                  _buildLogoSection(),

                  SizedBox(height: 8.h),

                  // Loading indicator section
                  _buildLoadingSection(),

                  // Spacer to balance layout
                  const Spacer(flex: 3),

                  // App version and branding
                  _buildBrandingSection(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Transform.scale(
      scale: _logoScaleAnimation.value,
      child: Opacity(
        opacity: _logoOpacityAnimation.value,
        child: Column(
          children: [
            // University logo container
            Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'school',
                  color: Colors.white,
                  size: 12.w,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // App name
            Text(
              'UniMark',
              style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            // Tagline
            Text(
              'Secure Attendance Management',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Loading indicator
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Status text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _initializationStatus,
            key: ValueKey(_initializationStatus),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      children: [
        // University branding
        Text(
          'Darshan University',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),

        SizedBox(height: 1.h),

        // Version info
        Text(
          'Version 1.0.0',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
