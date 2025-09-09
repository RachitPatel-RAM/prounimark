import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:unimark/services/biometric_service.dart';

import 'biometric_service_test.mocks.dart';

@GenerateMocks([LocalAuthentication])
void main() {
  group('BiometricService', () {
    late BiometricService biometricService;
    late MockLocalAuthentication mockLocalAuth;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      biometricService = BiometricService();
    });

    group('checkBiometricAvailability', () {
      test('should return available when biometrics are supported and enrolled', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => [
          BiometricType.fingerprint,
          BiometricType.face,
        ]);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, equals(BiometricAvailability.available));
      });

      test('should return not supported when device does not support biometrics', () async {
        // Arrange
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, equals(BiometricAvailability.notSupported));
      });

      test('should return not available when biometrics cannot be checked', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, equals(BiometricAvailability.notAvailable));
      });

      test('should return not enrolled when no biometrics are available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => []);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, equals(BiometricAvailability.notEnrolled));
      });

      test('should return error when exception occurs', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenThrow(Exception('Test error'));

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, equals(BiometricAvailability.error));
      });
    });

    group('authenticate', () {
      test('should return success when authentication succeeds', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => [
          BiometricType.fingerprint,
        ]);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          authMessages: anyNamed('authMessages'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await biometricService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should return failure when authentication fails', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => [
          BiometricType.fingerprint,
        ]);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          authMessages: anyNamed('authMessages'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // Act
        final result = await biometricService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Authentication cancelled or failed'));
      });

      test('should return failure when biometrics are not available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await biometricService.authenticateWithBiometrics(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Biometric authentication not available'));
      });
    });

    group('getBiometricTypeName', () {
      test('should return correct names for biometric types', () {
        expect(biometricService.getBiometricTypeName(BiometricType.fingerprint), equals('Fingerprint'));
        expect(biometricService.getBiometricTypeName(BiometricType.face), equals('Face ID'));
        expect(biometricService.getBiometricTypeName(BiometricType.iris), equals('Iris'));
        expect(biometricService.getBiometricTypeName(BiometricType.strong), equals('Strong Biometric'));
        expect(biometricService.getBiometricTypeName(BiometricType.weak), equals('Weak Biometric'));
      });
    });

    group('isValidPin', () {
      test('should return true for valid 4-digit PINs', () {
        expect(biometricService.isValidPin('1234'), isTrue);
        expect(biometricService.isValidPin('0000'), isTrue);
        expect(biometricService.isValidPin('9999'), isTrue);
      });

      test('should return false for invalid PINs', () {
        expect(biometricService.isValidPin('123'), isFalse); // Too short
        expect(biometricService.isValidPin('12345'), isFalse); // Too long
        expect(biometricService.isValidPin('12a4'), isFalse); // Contains letter
        expect(biometricService.isValidPin('12-4'), isFalse); // Contains dash
        expect(biometricService.isValidPin(''), isFalse); // Empty
      });
    });

    group('getPinValidationError', () {
      test('should return null for valid PINs', () {
        expect(biometricService.getPinValidationError('1234'), isNull);
        expect(biometricService.getPinValidationError('0000'), isNull);
      });

      test('should return error message for invalid PINs', () {
        expect(biometricService.getPinValidationError(''), equals('PIN is required'));
        expect(biometricService.getPinValidationError('123'), equals('PIN must be exactly 4 digits'));
        expect(biometricService.getPinValidationError('12a4'), equals('PIN must contain only numbers'));
      });
    });
  });
}
