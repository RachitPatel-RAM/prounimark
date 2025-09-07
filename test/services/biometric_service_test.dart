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
        expect(result, isA<BiometricAvailable>());
        if (result is BiometricAvailable) {
          expect(result.types, contains(BiometricType.fingerprint));
          expect(result.types, contains(BiometricType.face));
        }
      });

      test('should return not supported when device does not support biometrics', () async {
        // Arrange
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, isA<BiometricNotSupported>());
      });

      test('should return not available when biometrics cannot be checked', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, isA<BiometricNotAvailable>());
      });

      test('should return not enrolled when no biometrics are available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => []);

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, isA<BiometricNotEnrolled>());
      });

      test('should return error when exception occurs', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenThrow(Exception('Test error'));

        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, isA<BiometricError>());
        if (result is BiometricError) {
          expect(result.message, contains('Test error'));
        }
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
        final result = await biometricService.authenticate(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.error, isNull);
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
        final result = await biometricService.authenticate(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('Authentication cancelled or failed'));
      });

      test('should return failure when biometrics are not available', () async {
        // Arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // Act
        final result = await biometricService.authenticate(
          reason: 'Test authentication',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('Biometric authentication not available'));
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

    group('getPrimaryBiometricTypeName', () {
      test('should return Face ID when available', () {
        final types = [BiometricType.face, BiometricType.fingerprint];
        expect(biometricService.getPrimaryBiometricTypeName(types), equals('Face ID'));
      });

      test('should return Fingerprint when Face ID not available', () {
        final types = [BiometricType.fingerprint, BiometricType.strong];
        expect(biometricService.getPrimaryBiometricTypeName(types), equals('Fingerprint'));
      });

      test('should return Iris when others not available', () {
        final types = [BiometricType.iris];
        expect(biometricService.getPrimaryBiometricTypeName(types), equals('Iris'));
      });

      test('should return Biometric for unknown types', () {
        final types = [BiometricType.strong, BiometricType.weak];
        expect(biometricService.getPrimaryBiometricTypeName(types), equals('Strong Biometric'));
      });
    });
  });

  group('PinService', () {
    late PinService pinService;

    setUp(() {
      pinService = PinService();
    });

    group('isValidPinFormat', () {
      test('should return true for valid 4-digit PINs', () {
        expect(pinService.isValidPinFormat('1234'), isTrue);
        expect(pinService.isValidPinFormat('0000'), isTrue);
        expect(pinService.isValidPinFormat('9999'), isTrue);
      });

      test('should return false for invalid PINs', () {
        expect(pinService.isValidPinFormat('123'), isFalse); // Too short
        expect(pinService.isValidPinFormat('12345'), isFalse); // Too long
        expect(pinService.isValidPinFormat('12a4'), isFalse); // Contains letter
        expect(pinService.isValidPinFormat('12-4'), isFalse); // Contains dash
        expect(pinService.isValidPinFormat(''), isFalse); // Empty
      });
    });

    group('isStrongPin', () {
      test('should return true for strong PINs', () {
        expect(pinService.isStrongPin('1234'), isTrue);
        expect(pinService.isStrongPin('1357'), isTrue);
        expect(pinService.isStrongPin('2468'), isTrue);
      });

      test('should return false for weak PINs', () {
        expect(pinService.isStrongPin('0000'), isFalse); // All same
        expect(pinService.isStrongPin('1111'), isFalse); // All same
        expect(pinService.isStrongPin('9999'), isFalse); // All same
      });

      test('should return false for invalid length', () {
        expect(pinService.isStrongPin('123'), isFalse);
        expect(pinService.isStrongPin('12345'), isFalse);
      });
    });

    group('maskPin', () {
      test('should mask PIN with asterisks', () {
        expect(pinService.maskPin('1234'), equals('****'));
        expect(pinService.maskPin('12'), equals('**'));
        expect(pinService.maskPin('123456'), equals('******'));
      });
    });

    group('generateRandomPin', () {
      test('should generate 4-digit PIN', () {
        final pin = pinService.generateRandomPin();
        expect(pin.length, equals(4));
        expect(pinService.isValidPinFormat(pin), isTrue);
      });
    });
  });
}
