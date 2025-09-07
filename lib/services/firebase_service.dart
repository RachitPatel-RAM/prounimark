import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_functions/firebase_functions.dart'; // Discontinued
// import 'package:firebase_app_check/firebase_app_check.dart'; // Unused
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';
import '../models/hierarchy_model.dart';
// import 'auth_service.dart'; // Unused
// import 'location_service.dart'; // Unused
// import 'biometric_service.dart'; // Unused

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Authentication Methods
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('User creation failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // User Management
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<UserModel>> getStudentsByBranchClassBatch(String branch, String className, List<String> batches) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('branch', isEqualTo: branch)
          .where('className', isEqualTo: className)
          .where('batch', whereIn: batches)
          .get();
      
      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }

  // Session Management
  Future<String> createSession(SessionModel session) async {
    try {
      final docRef = await _firestore.collection('sessions').add(session.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  Future<List<SessionModel>> getActiveSessionsForStudent(String branch, String className, String batch) async {
    try {
      final query = await _firestore
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .where('branch', isEqualTo: branch)
          .where('className', isEqualTo: className)
          .where('batches', arrayContains: batch)
          .get();
      
      return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active sessions: $e');
    }
  }

  Future<List<SessionModel>> getSessionsByFaculty(String facultyId) async {
    try {
      final query = await _firestore
          .collection('sessions')
          .where('facultyId', isEqualTo: facultyId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get faculty sessions: $e');
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'isActive': false,
        'endTime': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to end session: $e');
    }
  }

  String generateSessionCode() {
    final random = Random();
    return (100 + random.nextInt(900)).toString(); // 3-digit code
  }

  // Attendance Management
  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(attendance.sessionId)
          .collection('attendance')
          .doc(attendance.studentUid)
          .set(attendance.toFirestore());
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  Future<AttendanceModel?> getAttendance(String sessionId, String studentId) async {
    try {
      final doc = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('attendance')
          .doc(studentId)
          .get();
      
      if (doc.exists) {
        return AttendanceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  Future<List<AttendanceModel>> getAttendanceHistory(String studentId) async {
    try {
      final query = await _firestore
          .collectionGroup('attendance')
          .where('studentUid', isEqualTo: studentId)
          .orderBy('submittedAt', descending: true)
          .get();
      
      return query.docs.map((doc) => AttendanceModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get attendance history: $e');
    }
  }

  Future<List<AttendanceModel>> getSessionAttendance(String sessionId) async {
    try {
      final query = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('attendance')
          .get();
      
      return query.docs.map((doc) => AttendanceModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get session attendance: $e');
    }
  }

  // Hierarchy Management
  Future<String> createBranch(BranchModel branch) async {
    try {
      final docRef = await _firestore.collection('branches').add(branch.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  Future<List<BranchModel>> getBranches() async {
    try {
      final query = await _firestore
          .collection('branches')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return query.docs.map((doc) => BranchModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get branches: $e');
    }
  }

  Future<String> createClass(ClassModel classModel) async {
    try {
      final docRef = await _firestore.collection('classes').add(classModel.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create class: $e');
    }
  }

  Future<List<ClassModel>> getClassesByBranch(String branchId) async {
    try {
      final query = await _firestore
          .collection('classes')
          .where('branchId', isEqualTo: branchId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return query.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get classes: $e');
    }
  }

  Future<String> createBatch(BatchModel batch) async {
    try {
      final docRef = await _firestore.collection('batches').add(batch.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create batch: $e');
    }
  }

  Future<List<BatchModel>> getBatchesByClass(String classId) async {
    try {
      final query = await _firestore
          .collection('batches')
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return query.docs.map((doc) => BatchModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get batches: $e');
    }
  }

  // Location Services
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  // Device Management
  Future<String> getDeviceId() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      throw Exception('Failed to get device ID: $e');
    }
  }

  // Admin Methods
  Future<List<UserModel>> getAllUsers() async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> updateAttendance(String sessionId, String studentId, AttendanceStatus status, String editedBy) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('attendance')
          .doc(studentId)
          .update({
        'status': status.toString().split('.').last,
        'isEdited': true,
        'editedAt': Timestamp.now(),
        'editedBy': editedBy,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  // Password change method
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Hierarchy management methods
  Future<List<BranchModel>> getHierarchy() async {
    try {
      final query = await _firestore
          .collection('branches')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return query.docs.map((doc) => BranchModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get hierarchy: $e');
    }
  }

  Future<void> addHierarchyLevel(BranchModel branch) async {
    try {
      await _firestore.collection('branches').add(branch.toFirestore());
    } catch (e) {
      throw Exception('Failed to add hierarchy level: $e');
    }
  }

  Future<void> updateHierarchyLevel(BranchModel branch) async {
    try {
      await _firestore.collection('branches').doc(branch.id).update(branch.toFirestore());
    } catch (e) {
      throw Exception('Failed to update hierarchy level: $e');
    }
  }

  Future<void> deleteHierarchyLevel(String branchId) async {
    try {
      await _firestore.collection('branches').doc(branchId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete hierarchy level: $e');
    }
  }
}
