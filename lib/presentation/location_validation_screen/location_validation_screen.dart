import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_validation_service.dart';

class LocationValidationScreen extends StatefulWidget {
  const LocationValidationScreen({super.key});

  @override
  State<LocationValidationScreen> createState() => _LocationValidationScreenState();
}

class _LocationValidationScreenState extends State<LocationValidationScreen>
    with TickerProviderStateMixin {
  final LocationValidationService _locationService = LocationValidationService();
  
  bool _isValidating = false;
  bool _isRetrying = false;
  LocationValidationResult? _lastResult;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _validateLocation();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _validateLocation() async {
    setState(() {
      _isValidating = true;
    });

    final result = await _locationService.validateLocationAccess();
    
    setState(() {
      _isValidating = false;
      _lastResult = result;
    });

    if (result.isSuccess) {
      // Location is valid, navigate to next screen
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    }
  }

  Future<void> _retryValidation() async {
    setState(() {
      _isRetrying = true;
    });

    HapticFeedback.lightImpact();
    await _validateLocation();
    
    setState(() {
      _isRetrying = false;
    });
  }

  Future<void> _openLocationSettings() async {
    HapticFeedback.lightImpact();
    await _locationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    HapticFeedback.lightImpact();
    await _locationService.openAppSettings();
  }

  Widget _buildLocationIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isValidating ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isValidating 
                  ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.location_on,
              size: 10.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage() {
    if (_isValidating) {
      return Column(
        children: [
          Text(
            'Validating Location Access',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'Please wait while we check your location settings...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_lastResult?.isSuccess == true) {
      return Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 8.w,
            color: Colors.green,
          ),
          SizedBox(height: 2.h),
          Text(
            'Location Access Verified',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'You can now proceed to login',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: [
        Icon(
          Icons.location_off,
          size: 8.w,
          color: Colors.red,
        ),
        SizedBox(height: 2.h),
        Text(
          'Location Access Required',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          _lastResult?.errorMessage ?? 'Location access is required to use this application',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isValidating) {
      return const SizedBox.shrink();
    }

    if (_lastResult?.isSuccess == true) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 4.h),
        
        // Retry button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isRetrying ? null : _retryValidation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isRetrying
                ? SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Retry',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Open settings button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: _openLocationSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Open Location Settings',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        if (_lastResult?.errorType == LocationValidationError.permissionDeniedForever) ...[
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton(
              onPressed: _openAppSettings,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                side: BorderSide(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Open App Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 12.w,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Title
                Text(
                  'UniMark',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 1.h),
                
                Text(
                  'Secure Attendance Management',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Location icon
                _buildLocationIcon(),
                
                SizedBox(height: 4.h),
                
                // Status message
                _buildStatusMessage(),
                
                // Action buttons
                _buildActionButtons(),
                
                SizedBox(height: 4.h),
                
                // Info text
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Location access is mandatory for all users to ensure secure attendance tracking and prevent unauthorized access.',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
