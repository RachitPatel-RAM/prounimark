import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Constants
  static const String _universityDomain = '@darshan.ac.in';
  static const String _adminId = 'ADMIN404';
  static const String _adminPassword = 'ADMIN9090@@@@';
  static const String _deviceBindingKey = 'device_binding_uuid';

  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Google Sign-In with domain restriction
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Sign out any existing Google session
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure('Sign-in cancelled by user');
      }

      // Check domain restriction
      if (!googleUser.email.endsWith(_universityDomain)) {
        await _googleSignIn.signOut();
        return AuthResult.failure(
          'Access denied. Only @darshan.ac.in email addresses are allowed.'
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // First time user - needs registration
        return AuthResult.needsRegistration(userCredential.user!);
      }

      final userModel = UserModel.fromFirestore(userDoc);
      return AuthResult.success(userModel);

    } catch (e) {
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  /// Admin login with static credentials
  Future<AuthResult> adminLogin(String adminId, String password) async {
    try {
      if (adminId != _adminId || password != _adminPassword) {
        return AuthResult.failure('Invalid admin credentials');
      }

      // Call Cloud Function for admin authentication
      final callable = _functions.httpsCallable('adminLogin');
      final result = await callable.call({
        'adminId': adminId,
        'password': password,
      });

      if (result.data['success'] == true) {
        // Create admin user model
        final adminUser = UserModel(
          id: 'admin',
          name: 'System Administrator',
          email: 'admin@darshan.ac.in',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        return AuthResult.success(adminUser);
      } else {
        return AuthResult.failure(result.data['error'] ?? 'Admin authentication failed');
      }

    } catch (e) {
      return AuthResult.failure('Admin login failed: $e');
    }
  }

  /// Complete student registration
  Future<AuthResult> completeStudentRegistration({
    required String enrollmentNo,
    required String branchId,
    required String classId,
    required String batchId,
    String? phone,
    String? pin,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found');
      }

      // Generate device binding UUID
      final deviceUuid = await _generateDeviceUuid();
      final instIdHash = await _generateInstIdHash(deviceUuid);

      // Call Cloud Function to complete registration
      final callable = _functions.httpsCallable('completeStudentRegistration');
      final result = await callable.call({
        'enrollmentNo': enrollmentNo.toUpperCase(),
        'branchId': branchId,
        'classId': classId,
        'batchId': batchId,
        'phone': phone,
        'pin': pin,
        'deviceUuid': deviceUuid,
        'instIdHash': instIdHash,
      });

      if (result.data['success'] == true) {
        // Get updated user data
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final userModel = UserModel.fromFirestore(userDoc);
        return AuthResult.success(userModel);
      } else {
        return AuthResult.failure(result.data['error'] ?? 'Registration failed');
      }

    } catch (e) {
      return AuthResult.failure('Registration failed: $e');
    }
  }

  /// Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      // Handle sign out errors silently
    }
  }

  /// Generate device UUID and store securely
  Future<String> _generateDeviceUuid() async {
    try {
      // Check if UUID already exists
      String? existingUuid = await _secureStorage.read(key: _deviceBindingKey);
      if (existingUuid != null && existingUuid.isNotEmpty) {
        return existingUuid;
      }

      // Generate new UUID
      final random = Random.secure();
      final bytes = List<int>.generate(16, (i) => random.nextInt(256));
      final uuid = base64Encode(bytes);
      
      // Store securely
      await _secureStorage.write(key: _deviceBindingKey, value: uuid);
      return uuid;
    } catch (e) {
      // Fallback to simple UUID generation
      final random = Random.secure();
      final bytes = List<int>.generate(16, (i) => random.nextInt(256));
      return base64Encode(bytes);
    }
  }

  /// Generate installation ID hash
  Future<String> _generateInstIdHash(String deviceUuid) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await _deviceInfo.deviceInfo;
      
      String platform;
      String packageName;
      
      if (deviceInfo is AndroidDeviceInfo) {
        platform = 'android';
        packageName = packageInfo.packageName;
      } else if (deviceInfo is IosDeviceInfo) {
        platform = 'ios';
        packageName = packageInfo.packageName;
      } else {
        platform = 'unknown';
        packageName = packageInfo.packageName;
      }

      final input = '$platform|$packageName|$deviceUuid';
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      // Fallback hash generation
      final input = 'unknown|unknown|$deviceUuid';
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }
  }

  /// Get device binding info
  Future<DeviceBindingInfo?> getDeviceBindingInfo() async {
    try {
      final deviceUuid = await _generateDeviceUuid();
      final instIdHash = await _generateInstIdHash(deviceUuid);
      
      return DeviceBindingInfo(
        deviceUuid: deviceUuid,
        instIdHash: instIdHash,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user needs to complete registration
  Future<bool> needsRegistration() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return !userDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Verify PIN for attendance
  Future<bool> verifyPin(String pin) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final callable = _functions.httpsCallable('verifyPin');
      final result = await callable.call({
        'pin': pin,
      });

      return result.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Reset device binding (admin only)
  Future<bool> resetDeviceBinding(String userId, String reason) async {
    try {
      final callable = _functions.httpsCallable('resetDeviceBinding');
      final result = await callable.call({
        'userId': userId,
        'reason': reason,
      });

      return result.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

/// Authentication result class
class AuthResult {
  final bool isSuccess;
  final bool needsRegistration;
  final String? error;
  final UserModel? user;
  final User? firebaseUser;

  AuthResult._({
    required this.isSuccess,
    required this.needsRegistration,
    this.error,
    this.user,
    this.firebaseUser,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(
      isSuccess: true,
      needsRegistration: false,
      user: user,
    );
  }

  factory AuthResult.needsRegistration(User firebaseUser) {
    return AuthResult._(
      isSuccess: false,
      needsRegistration: true,
      firebaseUser: firebaseUser,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      needsRegistration: false,
      error: error,
    );
  }
}

/// Device binding information
class DeviceBindingInfo {
  final String deviceUuid;
  final String instIdHash;

  DeviceBindingInfo({
    required this.deviceUuid,
    required this.instIdHash,
  });
}
