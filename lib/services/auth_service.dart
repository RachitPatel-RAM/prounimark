import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '36244654330-tr7dcuaqgjots2iadgmpq71bde5bo2gt.apps.googleusercontent.com',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Constants
  static const String _universityDomain = '@darshan.ac.in';
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

      // Check domain restriction for students
      if (!googleUser.email.endsWith(_universityDomain)) {
        await _googleSignIn.signOut();
        return AuthResult.failure(
          'Only official university email allowed. Please use your @darshan.ac.in account.'
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Validate authentication tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        await _googleSignIn.signOut();
        return AuthResult.failure('Failed to obtain authentication tokens');
      }

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

    } on PlatformException catch (e) {
      // Handle specific Google Sign-In errors
      String errorMessage = 'Google sign-in failed';
      
      if (e.code == 'sign_in_failed') {
        if (e.message?.contains('ApiException: 10') == true) {
          errorMessage = 'Google Sign-In configuration error. Please contact support.';
        } else if (e.message?.contains('ApiException: 7') == true) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.message?.contains('ApiException: 12501') == true) {
          errorMessage = 'Sign-in was cancelled by user.';
        } else {
          errorMessage = 'Google Sign-In failed: ${e.message}';
        }
      }
      
      return AuthResult.failure(errorMessage);
    } catch (e) {
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  /// Faculty login with Google SSO
  Future<AuthResult> facultyLoginWithGoogle() async {
    try {
      // Use regular Google Sign-In
      final result = await signInWithGoogle();
      
      // If successful, verify faculty role
      if (result.isSuccess && result.user != null) {
        if (result.user!.role != UserRole.faculty) {
          // User is not faculty, sign them out
          await signOut();
          return AuthResult.failure('Access denied. Faculty role required.');
        }
      }
      
      return result;
    } catch (e) {
      return AuthResult.failure('Faculty login failed: $e');
    }
  }

  /// Admin login with static credentials
  Future<AuthResult> adminLogin(String adminId, String password) async {
    try {
      // For now, use direct admin creation since cloud functions might not be deployed
      // In production, this should call the deployed cloud function
      if (adminId != 'ADMIN' || password != 'ADMIN9090') {
        return AuthResult.failure('Invalid admin credentials');
      }

      // Check if admin user exists in Firestore
      final adminDoc = await _firestore.collection('users').doc('admin').get();
      
      if (!adminDoc.exists) {
        // Create admin user if it doesn't exist
        final adminUser = UserModel(
          id: 'admin',
          name: 'System Administrator',
          email: 'admin@darshan.ac.in',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Store admin user in Firestore
        await _firestore.collection('users').doc('admin').set(adminUser.toFirestore());
        return AuthResult.success(adminUser);
      } else {
        // Admin user exists, return it
        final adminUser = UserModel.fromFirestore(adminDoc);
        return AuthResult.success(adminUser);
      }

    } catch (e) {
      return AuthResult.failure('Admin login failed: $e');
    }
  }

  /// Create faculty user (admin only)
  Future<AuthResult> createFacultyUser({
    required String email,
    required String name,
    required String branchId,
    String? phone,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return AuthResult.failure('Faculty user with this email already exists');
      }

      // Create faculty user document
      final facultyUser = UserModel(
        id: 'faculty_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: UserRole.faculty,
        branch: branchId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store in Firestore
      await _firestore.collection('users').doc(facultyUser.id).set(facultyUser.toFirestore());
      
      return AuthResult.success(facultyUser);

    } catch (e) {
      return AuthResult.failure('Failed to create faculty user: $e');
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
    bool biometricEnabled = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found');
      }

      // Check if enrollment number already exists
      final enrollmentQuery = await _firestore
          .collection('users')
          .where('enrollmentNo', isEqualTo: enrollmentNo.toUpperCase())
          .limit(1)
          .get();

      if (enrollmentQuery.docs.isNotEmpty) {
        return AuthResult.failure('Enrollment number already registered');
      }

      // Generate device binding UUID
      final deviceUuid = await _generateDeviceUuid();
      final instIdHash = await _generateInstIdHash(deviceUuid);

      // Create user model with all required fields
      final userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? 'Student',
        email: user.email ?? '',
        role: UserRole.student,
        enrollmentNo: enrollmentNo.toUpperCase(),
        branch: branchId,
        classId: classId,
        batchId: batchId,
        deviceBinding: DeviceBinding(
          instIdHash: instIdHash,
          platform: await _getPlatform(),
          boundAt: DateTime.now(),
        ),
        pinHash: pin != null ? _hashPin(pin) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());
      
      // Store device binding separately for security
      await _firestore.collection('device_bindings').doc(user.uid).set({
        'userId': user.uid,
        'deviceUuid': deviceUuid,
        'instIdHash': instIdHash,
        'platform': await _getPlatform(),
        'boundAt': DateTime.now(),
        'isActive': true,
      });
      
      return AuthResult.success(userModel);

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

  /// Get all faculty users (admin only)
  Future<List<UserModel>> getAllFacultyUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all student users (admin only)
  Future<List<UserModel>> getAllStudentUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Faculty login with email and password
  Future<AuthResult> signInFacultyWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email domain
      if (!email.endsWith(_universityDomain)) {
        return AuthResult.failure('Invalid email domain. Use @darshan.ac.in email.');
      }

      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Authentication failed');
      }

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        await _auth.signOut();
        return AuthResult.failure('User data not found');
      }

      final userData = userDoc.data()!;
      final userRole = userData['role'] as String?;

      // Verify faculty role
      if (userRole != 'faculty') {
        await _auth.signOut();
        return AuthResult.failure('Access denied. Faculty account required.');
      }

      // Check if user is active
      if (userData['isActive'] != true) {
        await _auth.signOut();
        return AuthResult.failure('Account is deactivated');
      }

      // Device binding check
      final deviceUuid = await _generateDeviceUuid();
      final existingDeviceBinding = await _firestore
          .collection('device_bindings')
          .doc(credential.user!.uid)
          .get();

      if (existingDeviceBinding.exists) {
        final bindingData = existingDeviceBinding.data()!;
        final storedDeviceUuid = bindingData['deviceUuid'] as String?;
        
        if (storedDeviceUuid != null && storedDeviceUuid != deviceUuid) {
          await _auth.signOut();
          return AuthResult.failure('Account is already active on another device');
        }
      }

      // Update device binding
      await _firestore.collection('device_bindings').doc(credential.user!.uid).set({
        'userId': credential.user!.uid,
        'deviceUuid': deviceUuid,
        'instIdHash': await _generateInstIdHash(deviceUuid),
        'platform': await _getPlatform(),
        'boundAt': DateTime.now(),
        'isActive': true,
        'lastLogin': DateTime.now(),
      });

      // Update last login
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Log successful login
      await _firestore.collection('auditLogs').add({
        'eventType': 'FACULTY_LOGIN',
        'facultyUid': credential.user!.uid,
        'email': email,
        'timestamp': DateTime.now(),
        'deviceUuid': deviceUuid,
      });

      final userModel = UserModel.fromFirestore(userDoc);
      return AuthResult.success(userModel);

    } catch (e) {
      return AuthResult.failure('Login failed: $e');
    }
  }

  /// Create faculty user via Cloud Function (admin only)
  Future<AuthResult> createFacultyUserViaFunction({
    required String email,
    required String name,
    String? branchId,
    String? temporaryPassword,
  }) async {
    try {
      // For development: Direct faculty creation
      // In production, this should call your deployed Cloud Function via HTTP
      final result = await createFacultyUser(
        email: email,
        name: name,
        branchId: branchId ?? '',
      );
      
      return result;
    } catch (e) {
      return AuthResult.failure('Failed to create faculty user: $e');
    }
  }

  /// Update faculty user (admin only)
  Future<AuthResult> updateFacultyUser({
    required String facultyId,
    String? name,
  }) async {
    try {
      if (name != null && name.trim().isNotEmpty) {
        await _firestore.collection('users').doc(facultyId).update({
          'name': name.trim(),
          'updatedAt': DateTime.now(),
        });
      }

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'FACULTY_UPDATED',
        'adminUid': _auth.currentUser?.uid,
        'facultyUid': facultyId,
        'changes': name != null ? {'name': name.trim()} : {},
        'timestamp': DateTime.now(),
      });

      return AuthResult.success(UserModel(
        id: facultyId,
        name: name ?? 'Faculty',
        email: '',
        role: UserRole.faculty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return AuthResult.failure('Failed to update faculty user: $e');
    }
  }

  /// Delete faculty user (admin only)
  Future<AuthResult> deleteFacultyUser(String facultyId) async {
    try {
      // Check if faculty has any active sessions
      final activeSessions = await _firestore
          .collection('sessions')
          .where('facultyId', isEqualTo: facultyId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (activeSessions.docs.isNotEmpty) {
        return AuthResult.failure('Cannot delete faculty with active sessions. Please close all sessions first.');
      }

      // Get faculty data before deletion for logging
      final facultyDoc = await _firestore.collection('users').doc(facultyId).get();
      final facultyData = facultyDoc.data();

      // Delete user document
      await _firestore.collection('users').doc(facultyId).delete();

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'FACULTY_DELETED',
        'adminUid': _auth.currentUser?.uid,
        'facultyUid': facultyId,
        'facultyEmail': facultyData?['email'],
        'facultyName': facultyData?['name'],
        'timestamp': DateTime.now(),
      });

      return AuthResult.success(UserModel(
        id: facultyId,
        name: facultyData?['name'] ?? 'Faculty',
        email: facultyData?['email'] ?? '',
        role: UserRole.faculty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return AuthResult.failure('Failed to delete faculty user: $e');
    }
  }

  /// Faculty password reset (faculty can change their own password)
  Future<AuthResult> resetFacultyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No authenticated user found');
      }

      // Verify current password by re-authenticating
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Update user model to mark password as changed
      await _firestore.collection('users').doc(user.uid).update({
        'tempPassword': false,
        'updatedAt': DateTime.now(),
      });

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'FACULTY_PASSWORD_CHANGED',
        'facultyUid': user.uid,
        'email': user.email,
        'timestamp': DateTime.now(),
      });

      return AuthResult.success(UserModel(
        id: user.uid,
        name: user.displayName ?? 'Faculty',
        email: user.email ?? '',
        role: UserRole.faculty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tempPassword: false,
      ));
    } catch (e) {
      return AuthResult.failure('Failed to reset password: $e');
    }
  }

  /// Reset faculty password (admin only)
  Future<AuthResult> adminResetFacultyPassword(String facultyId) async {
    try {
      // For development: Generate new password
      // In production, this should call your deployed Cloud Function via HTTP
      final newPassword = _generateTemporaryPassword();

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'FACULTY_PASSWORD_RESET_BY_ADMIN',
        'adminUid': _auth.currentUser?.uid,
        'facultyUid': facultyId,
        'newPassword': newPassword, // Include the new password in the log
        'timestamp': DateTime.now(),
      });

      return AuthResult.success(UserModel(
        id: facultyId,
        name: 'Faculty',
        email: '',
        role: UserRole.faculty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return AuthResult.failure('Failed to reset faculty password: $e');
    }
  }

  /// Generate temporary password
  String _generateTemporaryPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
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

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;
      final storedPinHash = userData['pinHash'] as String?;
      
      if (storedPinHash == null) return false;

      // Verify PIN hash
      final inputPinHash = _hashPin(pin);
      return inputPinHash == storedPinHash;
    } catch (e) {
      return false;
    }
  }

  /// Reset device binding (admin only)
  Future<bool> resetDeviceBinding(String userId, String reason) async {
    try {
      // For development: Direct device binding reset
      // In production, this should call your deployed Cloud Function via HTTP
      await _firestore.collection('users').doc(userId).update({
        'deviceBinding': null,
        'updatedAt': DateTime.now(),
      });

      // Log the reset action
      await _firestore.collection('auditLogs').add({
        'eventType': 'DEVICE_BINDING_RESET',
        'userId': userId,
        'reason': reason,
        'timestamp': DateTime.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to get platform
  Future<String> _getPlatform() async {
    try {
      final deviceInfo = await _deviceInfo.deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        return 'android';
      } else if (deviceInfo is IosDeviceInfo) {
        return 'ios';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Helper method to hash PIN
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
