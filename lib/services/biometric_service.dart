import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available
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

      return BiometricAvailability.available(availableBiometrics);
    } catch (e) {
      return BiometricAvailability.error(e.toString());
    }
  }

  /// Authenticate using biometric
  Future<BiometricResult> authenticate({
    String? reason,
    bool stickyAuth = true,
  }) async {
    try {
      final availability = await checkBiometricAvailability();
      if (availability is! BiometricAvailable) {
        return BiometricResult.failure('Biometric authentication not available');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to mark attendance',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device Credentials Required',
            deviceCredentialsSetupDescription: 'Device credentials are not set up on your device. Go to \'Settings > Security\' to set up a screen lock.',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up a screen lock in your device settings.',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Please set up Touch ID or Face ID on your device to use biometric authentication.',
            lockOut: 'Please reenable your Touch ID or Face ID',
          ),
        ],
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        return BiometricResult.success();
      } else {
        return BiometricResult.failure('Authentication cancelled or failed');
      }
    } on PlatformException catch (e) {
      return BiometricResult.failure(_getBiometricErrorMessage(e.code));
    } catch (e) {
      return BiometricResult.failure('Biometric authentication failed: $e');
    }
  }

  /// Get biometric types available on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
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

  /// Get user-friendly biometric type name
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

  /// Get primary biometric type name for display
  String getPrimaryBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Strong Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Weak Biometric';
    }
    return 'Biometric';
  }

  /// Get error message for biometric authentication
  String _getBiometricErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device';
      case 'NotEnrolled':
        return 'No biometric data is enrolled. Please set up biometric authentication in device settings';
      case 'LockedOut':
        return 'Biometric authentication is locked out. Please try again later or use device credentials';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is permanently locked out. Please use device credentials';
      case 'UserCancel':
        return 'Authentication was cancelled by user';
      case 'SystemCancel':
        return 'Authentication was cancelled by system';
      case 'PasscodeNotSet':
        return 'Device passcode is not set. Please set up a passcode in device settings';
      case 'TouchIDNotAvailable':
        return 'Touch ID is not available on this device';
      case 'TouchIDNotEnrolled':
        return 'Touch ID is not enrolled. Please set up Touch ID in device settings';
      case 'FaceIDNotAvailable':
        return 'Face ID is not available on this device';
      case 'FaceIDNotEnrolled':
        return 'Face ID is not enrolled. Please set up Face ID in device settings';
      case 'BiometricNotAvailable':
        return 'Biometric authentication is not available';
      case 'BiometricNotEnrolled':
        return 'Biometric authentication is not enrolled';
      case 'BiometricLockedOut':
        return 'Biometric authentication is locked out';
      case 'BiometricPermanentlyLockedOut':
        return 'Biometric authentication is permanently locked out';
      default:
        return 'Biometric authentication failed: $errorCode';
    }
  }
}

/// Biometric availability result
abstract class BiometricAvailability {
  const BiometricAvailability();
}

class BiometricAvailable extends BiometricAvailability {
  final List<BiometricType> types;
  const BiometricAvailable(this.types);
}

class BiometricNotSupported extends BiometricAvailability {
  const BiometricNotSupported();
}

class BiometricNotAvailable extends BiometricAvailability {
  const BiometricNotAvailable();
}

class BiometricNotEnrolled extends BiometricAvailability {
  const BiometricNotEnrolled();
}

class BiometricError extends BiometricAvailability {
  final String message;
  const BiometricError(this.message);
}

/// Biometric authentication result
class BiometricResult {
  final bool isSuccess;
  final String? error;

  BiometricResult._({
    required this.isSuccess,
    this.error,
  });

  factory BiometricResult.success() {
    return BiometricResult._(isSuccess: true);
  }

  factory BiometricResult.failure(String error) {
    return BiometricResult._(isSuccess: false, error: error);
  }
}

/// PIN validation service
class PinService {
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  /// Validate PIN format (4 digits)
  bool isValidPinFormat(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }

  /// Generate random 4-digit PIN for testing
  String generateRandomPin() {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return random.toString().padLeft(4, '0');
  }

  /// Mask PIN for display
  String maskPin(String pin) {
    return '*' * pin.length;
  }

  /// Validate PIN strength (basic validation)
  bool isStrongPin(String pin) {
    // Basic strength validation - not all same digits
    if (pin.length != 4) return false;
    
    // Check if all digits are the same
    final firstDigit = pin[0];
    for (int i = 1; i < pin.length; i++) {
      if (pin[i] != firstDigit) return true;
    }
    
    return false;
  }
}
