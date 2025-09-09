import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart' as attendance_model;
import 'location_service.dart' as location_service;

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new attendance session
  Future<AttendanceResult> createSession(SessionModel session) async {
    try {
      // Generate unique session code
      final sessionCode = _generateSessionCode();
      
      // Create session document
      final sessionData = session.copyWith(
        sessionCode: sessionCode,
        startTime: DateTime.now(),
        isActive: true,
      );

      final docRef = await _firestore.collection('sessions').add(sessionData.toFirestore());
      
      // Update session with generated ID
      await _firestore.collection('sessions').doc(docRef.id).update({
        'id': docRef.id,
      });

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'SESSION_CREATED',
        'facultyUid': session.facultyId,
        'sessionId': docRef.id,
        'sessionCode': sessionCode,
        'course': session.course,
        'className': session.className,
        'timestamp': DateTime.now(),
      });

      return AttendanceResult.success(sessionData.copyWith(id: docRef.id));
    } catch (e) {
      return AttendanceResult.failure('Failed to create session: $e');
    }
  }

  /// Get active session for a faculty member
  Future<SessionModel?> getActiveSession(String facultyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('facultyId', isEqualTo: facultyId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return SessionModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// Get session by ID
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();
      if (!doc.exists) {
        return null;
      }
      return SessionModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Get all sessions for a faculty member
  Future<List<SessionModel>> getFacultySessions(String facultyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('facultyId', isEqualTo: facultyId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// End an active session
  Future<AttendanceResult> endSession(String sessionId) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) {
        return AttendanceResult.failure('Session not found');
      }

      if (!session.isActive) {
        return AttendanceResult.failure('Session is already ended');
      }

      await _firestore.collection('sessions').doc(sessionId).update({
        'endTime': DateTime.now(),
        'isActive': false,
        'updatedAt': DateTime.now(),
      });

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'SESSION_ENDED',
        'facultyUid': session.facultyId,
        'sessionId': sessionId,
        'studentsPresent': session.studentsPresent.length,
        'timestamp': DateTime.now(),
      });

      return AttendanceResult.success(session);
    } catch (e) {
      return AttendanceResult.failure('Failed to end session: $e');
    }
  }

  /// Mark student attendance
  Future<AttendanceResult> markAttendance({
    required String sessionId,
    required String studentId,
    required location_service.LocationData studentLocation,
  }) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) {
        return AttendanceResult.failure('Session not found');
      }

      if (!session.isActive) {
        return AttendanceResult.failure('Session is not active');
      }

      // Check if session code is still valid (5 minutes)
      final sessionAge = DateTime.now().difference(session.startTime);
      if (sessionAge.inMinutes > 5) {
        return AttendanceResult.failure('Session code has expired');
      }

      // Check if student is already marked present
      if (session.studentsPresent.contains(studentId)) {
        return AttendanceResult.failure('Attendance already marked');
      }

      // Validate location (within 500m radius)
      final distance = _calculateDistance(
        session.gpsLocation.latitude,
        session.gpsLocation.longitude,
        studentLocation.latitude,
        studentLocation.longitude,
      );

      if (distance > session.radius) {
        return AttendanceResult.failure('You are outside the attendance radius (${distance.toStringAsFixed(0)}m away)');
      }

      // Add student to present list
      await _firestore.collection('sessions').doc(sessionId).update({
        'studentsPresent': FieldValue.arrayUnion([studentId]),
        'updatedAt': DateTime.now(),
      });

      // Create attendance record
      final attendance = attendance_model.AttendanceModel(
        id: '',
        sessionId: sessionId,
        studentId: studentId,
        studentUid: studentId,
        markedAt: DateTime.now(),
        submittedAt: DateTime.now(),
        location: studentLocation,
        distance: distance,
        isPresent: true,
        result: attendance_model.AttendanceResult.accepted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('attendance').add(attendance.toFirestore());

      // Log the action
      await _firestore.collection('auditLogs').add({
        'eventType': 'ATTENDANCE_MARKED',
        'sessionId': sessionId,
        'studentId': studentId,
        'distance': distance,
        'timestamp': DateTime.now(),
      });

      return AttendanceResult.success(session);
    } catch (e) {
      return AttendanceResult.failure('Failed to mark attendance: $e');
    }
  }

  /// Get attendance records for a session
  Future<List<attendance_model.AttendanceModel>> getSessionAttendance(String sessionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('markedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => attendance_model.AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get student attendance history
  Future<List<attendance_model.AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('markedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => attendance_model.AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate a unique 3-digit session code
  String _generateSessionCode() {
    final random = Random();
    return (100 + random.nextInt(900)).toString(); // 100-999
  }

  /// Calculate distance between two coordinates in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Check if student has already submitted attendance for a session
  Future<bool> hasAlreadySubmitted(String sessionId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Submit attendance for a student
  Future<AttendanceResult> submitAttendance({
    required String sessionId,
    required int responseCode,
    required bool useBiometric,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return AttendanceResult.failure('User not authenticated');
      }

      // Get current location
      final locationResult = await location_service.LocationService().getCurrentLocation();
      if (!locationResult.isSuccess) {
        return AttendanceResult.failure(locationResult.error!);
      }

      // Mark attendance
      final result = await markAttendance(
        sessionId: sessionId,
        studentId: currentUser.uid,
        studentLocation: locationResult.location!,
      );

      if (result.isSuccess) {
        return AttendanceResult.success('Attendance marked successfully');
      } else {
        return AttendanceResult.failure(result.error!);
      }
    } catch (e) {
      return AttendanceResult.failure('Failed to submit attendance: $e');
    }
  }

  /// Get attendance history for current user
  Future<List<attendance_model.AttendanceModel>> getAttendanceHistory() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: currentUser.uid)
          .orderBy('markedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => attendance_model.AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// Result class for attendance operations
class AttendanceResult {
  final bool isSuccess;
  final String? error;
  final dynamic data;

  AttendanceResult._({
    required this.isSuccess,
    this.error,
    this.data,
  });

  factory AttendanceResult.success(dynamic data) {
    return AttendanceResult._(isSuccess: true, data: data);
  }

  factory AttendanceResult.failure(String error) {
    return AttendanceResult._(isSuccess: false, error: error);
  }
}