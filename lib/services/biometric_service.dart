import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<BiometricAvailability> checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isDeviceSupported) {
        return BiometricAvailability.notSupported;
      }

      if (!isAvailable) {
        return BiometricAvailability.notAvailable;
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } catch (e) {
      return BiometricAvailability.error;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricResult> authenticateWithBiometrics({
    String reason = 'Please authenticate to continue',
    bool stickyAuth = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        return BiometricResult.success();
      } else {
        return BiometricResult.failure('Authentication cancelled or failed');
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Biometric authentication failed';
      
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometric data enrolled. Please set up biometric authentication in device settings.';
          break;
        case 'LockedOut':
          errorMessage = 'Biometric authentication is locked out. Please try again later.';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric authentication is permanently locked out. Please use device passcode.';
          break;
        case 'UserCancel':
          errorMessage = 'Authentication was cancelled by user';
          break;
        case 'AuthenticationInProgress':
          errorMessage = 'Authentication is already in progress';
          break;
        default:
          errorMessage = 'Biometric authentication failed: ${e.message}';
      }

      return BiometricResult.failure(errorMessage);
    } catch (e) {
      return BiometricResult.failure('Biometric authentication failed: $e');
    }
  }

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
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

  /// Get all biometric type names for display
  List<String> getBiometricTypeNames(List<BiometricType> types) {
    return types.map((type) => getBiometricTypeName(type)).toList();
  }

  /// Hash PIN for secure storage
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify PIN against hash
  bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  /// Validate PIN format (4 digits)
  bool isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }

  /// Get PIN validation error message
  String? getPinValidationError(String pin) {
    if (pin.isEmpty) {
      return 'PIN is required';
    }
    if (pin.length != 4) {
      return 'PIN must be exactly 4 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }
}

/// Biometric availability status
enum BiometricAvailability {
  available,
  notAvailable,
  notSupported,
  notEnrolled,
  error,
}

/// Biometric authentication result
class BiometricResult {
  final bool isSuccess;
  final String? errorMessage;

  BiometricResult._({
    required this.isSuccess,
    this.errorMessage,
  });

  factory BiometricResult.success() {
    return BiometricResult._(isSuccess: true);
  }

  factory BiometricResult.failure(String message) {
    return BiometricResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}