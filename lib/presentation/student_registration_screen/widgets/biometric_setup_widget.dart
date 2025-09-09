import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/biometric_service.dart';

class BiometricSetupWidget extends StatefulWidget {
  final bool isEnabled;
  final Function(bool) onToggle;

  const BiometricSetupWidget({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget> {
  final BiometricService _biometricService = BiometricService();
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBiometrics();
  }

  Future<void> _loadAvailableBiometrics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final biometrics = await _biometricService.getAvailableBiometrics();
      setState(() {
        _availableBiometrics = biometrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _biometricService.authenticateWithBiometrics(
        reason: 'Test biometric authentication for registration',
      );

      if (result.isSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result.errorMessage ?? 'Biometric authentication failed');
      }
    } catch (e) {
      _showErrorDialog('Biometric test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successLight,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Biometric Test Successful',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.successLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Your biometric authentication is working correctly. You can now use it for secure attendance marking.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue'),
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
              color: AppTheme.lightTheme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Biometric Test Failed',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _testBiometric();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.face:
        return Icons.face;
      case BiometricType.iris:
        return Icons.visibility;
      case BiometricType.strong:
        return Icons.security;
      case BiometricType.weak:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isEnabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: widget.isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: widget.isEnabled
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Biometric Authentication',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: widget.isEnabled,
                onChanged: widget.onToggle,
                activeThumbColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Use your biometric data (fingerprint, face ID, etc.) for secure attendance verification.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_availableBiometrics.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Available biometric methods:',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _availableBiometrics.map((type) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getBiometricIcon(type),
                        size: 4.w,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _getBiometricTypeName(type),
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          if (widget.isEnabled) ...[
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testBiometric,
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
                    : Icon(Icons.security),
                label: Text(_isLoading ? 'Testing...' : 'Test Biometric'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
