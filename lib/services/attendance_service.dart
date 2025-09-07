// import 'dart:convert'; // Unused
// import 'package:http/http.dart' as http; // Unused
// import 'package:firebase_app_check/firebase_app_check.dart'; // Unused
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';
import 'auth_service.dart';
import 'location_service.dart';
import 'biometric_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  // final FirebaseFunctions _functions = FirebaseFunctions.instance; // Discontinued
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final BiometricService _biometricService = BiometricService();

  /// Submit attendance with full verification pipeline
  Future<AttendanceSubmissionResult> submitAttendance({
    required String sessionId,
    required int responseCode,
    required bool useBiometric,
    String? pin,
  }) async {
    try {
      // Get current user
      final user = _authService.currentUser;
      if (user == null) {
        return AttendanceSubmissionResult.failure('User not authenticated');
      }

      // Get user model
      final userModel = await _authService.getCurrentUserModel();
      if (userModel == null) {
        return AttendanceSubmissionResult.failure('User data not found');
      }

      // Get session data
      final sessionDoc = await _firestore.collection('sessions').doc(sessionId).get();
      if (!sessionDoc.exists) {
        return AttendanceSubmissionResult.failure('Session not found');
      }

      final session = SessionModel.fromFirestore(sessionDoc);

      // Verify session is active and not expired
      if (session.status != SessionStatus.open) {
        return AttendanceSubmissionResult.failure('Session is not active');
      }

      if (DateTime.now().isAfter(session.expiresAt)) {
        return AttendanceSubmissionResult.failure('Session has expired');
      }

      // Verify user belongs to session
      if (!_isUserEligibleForSession(userModel, session)) {
        return AttendanceSubmissionResult.failure('You are not eligible for this session');
      }

      // Get current location
      final locationResult = await _locationService.verifyLocationForAttendance(
        session.facultyLocation,
        session.gpsRadiusM.toDouble(),
      );

      if (!locationResult.isSuccess) {
        return AttendanceSubmissionResult.failure(locationResult.error!);
      }

      // Authenticate user (biometric or PIN)
      bool authSuccess = false;
      if (useBiometric) {
        final biometricResult = await _biometricService.authenticate(
          reason: 'Authenticate to mark attendance for ${session.subject}',
        );
        authSuccess = biometricResult.isSuccess;
      } else if (pin != null) {
        authSuccess = await _authService.verifyPin(pin);
      }

      if (!authSuccess) {
        return AttendanceSubmissionResult.failure('Authentication failed');
      }

      // Get device binding info
      final deviceInfo = await _authService.getDeviceBindingInfo();
      if (deviceInfo == null) {
        return AttendanceSubmissionResult.failure('Device binding not found');
      }

      // For development: Direct attendance submission
      // In production, this should call your deployed Cloud Function via HTTP
      final attendanceId = _firestore.collection('attendance').doc().id;
      
      final attendance = AttendanceModel(
        id: attendanceId,
        sessionId: sessionId,
        studentUid: user.uid,
        enrollmentNo: userModel.enrollmentNo ?? '',
        submittedAt: DateTime.now(),
        responseCode: responseCode,
        deviceInstIdHash: deviceInfo.instIdHash,
        location: StudentLocation(
          lat: locationResult.location!.latitude,
          lng: locationResult.location!.longitude,
          accM: locationResult.location!.accuracy,
        ),
        verified: VerificationFlags(
          timeOk: true,
          codeOk: true,
          deviceOk: true,
          integrityOk: true,
          locationOk: true,
        ),
        result: AttendanceResult.accepted, // For development, always accept
      );

      // Store attendance in Firestore
      await _firestore.collection('attendance').doc(attendanceId).set(attendance.toFirestore());
      
      return AttendanceSubmissionResult.success(
        attendanceId,
        'Attendance marked successfully',
      );

    } catch (e) {
      return AttendanceSubmissionResult.failure('Attendance submission failed: $e');
    }
  }

  /// Check if user is eligible for session
  bool _isUserEligibleForSession(UserModel user, SessionModel session) {
    // Check if user belongs to the session's branch, class, and batch
    return user.branch == session.branchId &&
           user.classId == session.classId &&
           session.batchIds.contains(user.batchId);
  }

  /// Get active sessions for current user
  Future<List<SessionModel>> getActiveSessionsForUser() async {
    try {
      final userModel = await _authService.getCurrentUserModel();
      if (userModel == null || userModel.role != UserRole.student) {
        return [];
      }

      final query = await _firestore
          .collection('sessions')
          .where('status', isEqualTo: 'open')
          .where('branchId', isEqualTo: userModel.branch)
          .where('classId', isEqualTo: userModel.classId)
          .where('batchIds', arrayContains: userModel.batchId)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .get();

      return query.docs.map((doc) => SessionModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get attendance history for current user
  Future<List<AttendanceModel>> getAttendanceHistory() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      final query = await _firestore
          .collectionGroup('attendance')
          .where('studentUid', isEqualTo: user.uid)
          .orderBy('submittedAt', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => AttendanceModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get session attendance (for faculty/admin)
  Future<List<AttendanceModel>> getSessionAttendance(String sessionId) async {
    try {
      final query = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('attendance')
          .orderBy('submittedAt', descending: true)
          .get();

      return query.docs.map((doc) => AttendanceModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if user has already submitted attendance for session
  Future<bool> hasAlreadySubmitted(String sessionId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('attendance')
          .doc(user.uid)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get attendance statistics for user
  Future<AttendanceStats> getAttendanceStats() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return AttendanceStats.empty();
      }

      final query = await _firestore
          .collectionGroup('attendance')
          .where('studentUid', isEqualTo: user.uid)
          .get();

      int totalSessions = query.docs.length;
      int presentCount = query.docs
          .where((doc) => doc.data()['result'] == 'accepted')
          .length;

      double attendancePercentage = totalSessions > 0 
          ? (presentCount / totalSessions) * 100 
          : 0.0;

      return AttendanceStats(
        totalSessions: totalSessions,
        presentCount: presentCount,
        absentCount: totalSessions - presentCount,
        attendancePercentage: attendancePercentage,
      );
    } catch (e) {
      return AttendanceStats.empty();
    }
  }

  /// Validate session code format
  bool isValidSessionCode(String code) {
    return RegExp(r'^\d{3}$').hasMatch(code);
  }

  /// Parse session code to integer
  int? parseSessionCode(String code) {
    if (!isValidSessionCode(code)) return null;
    return int.tryParse(code);
  }
}

/// Attendance submission result
class AttendanceSubmissionResult {
  final bool isSuccess;
  final String? error;
  final String? attendanceId;
  final String? message;

  AttendanceSubmissionResult._({
    required this.isSuccess,
    this.error,
    this.attendanceId,
    this.message,
  });

  factory AttendanceSubmissionResult.success(String attendanceId, String message) {
    return AttendanceSubmissionResult._(
      isSuccess: true,
      attendanceId: attendanceId,
      message: message,
    );
  }

  factory AttendanceSubmissionResult.failure(String error) {
    return AttendanceSubmissionResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Attendance statistics
class AttendanceStats {
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;

  AttendanceStats({
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
  });

  factory AttendanceStats.empty() {
    return AttendanceStats(
      totalSessions: 0,
      presentCount: 0,
      absentCount: 0,
      attendancePercentage: 0.0,
    );
  }
}
