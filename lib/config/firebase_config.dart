import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  /// Initialize Firebase
  static Future<void> initialize() async {
    if (_app == null) {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      
      // Configure Firestore settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  /// Get Firebase App instance
  static FirebaseApp get app {
    if (_app == null) {
      throw Exception('Firebase not initialized. Call FirebaseConfig.initialize() first.');
    }
    return _app!;
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call FirebaseConfig.initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseConfig.initialize() first.');
    }
    return _firestore!;
  }

  /// Configure Firebase Auth settings
  static void configureAuth() {
    if (_auth != null) {
      // Set auth persistence
      _auth!.setSettings(
        appVerificationDisabledForTesting: false,
        forceRecaptchaFlow: false,
      );
    }
  }

  /// Configure Firestore settings
  static void configureFirestore() {
    if (_firestore != null) {
      // Enable offline persistence (deprecated method removed)
      
      // Configure cache settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  /// Get current user
  static User? get currentUser => _auth?.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth?.currentUser != null;

  /// Sign out current user
  static Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
  }

  /// Clear all Firebase instances (for testing)
  static Future<void> clear() async {
    if (_app != null) {
      await _app!.delete();
      _app = null;
      _auth = null;
      _firestore = null;
    }
  }
}

/// Firebase collection names
class FirebaseCollections {
  static const String users = 'users';
  static const String sessions = 'sessions';
  static const String branches = 'branches';
  static const String classes = 'classes';
  static const String batches = 'batches';
  static const String attendance = 'attendance';
  static const String sessionCodes = 'session_codes';
  static const String deviceBindings = 'device_bindings';
  static const String system = 'system';
  static const String auditLogs = 'audit_logs';
}

/// Firebase field names
class FirebaseFields {
  // User fields
  static const String userId = 'userId';
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';
  static const String enrollmentNumber = 'enrollmentNumber';
  static const String branch = 'branch';
  static const String className = 'className';
  static const String batch = 'batch';
  static const String deviceId = 'deviceId';
  static const String isActive = 'isActive';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // Session fields
  static const String sessionId = 'sessionId';
  static const String facultyId = 'facultyId';
  static const String facultyName = 'facultyName';
  static const String subject = 'subject';
  static const String code = 'code';
  static const String location = 'location';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String radius = 'radius';
  static const String sessionIsActive = 'isActive';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';

  // Attendance fields
  static const String studentId = 'studentId';
  static const String studentName = 'studentName';
  static const String status = 'status';
  static const String timestamp = 'timestamp';
  static const String notes = 'notes';
  static const String isEdited = 'isEdited';
  static const String editedAt = 'editedAt';
  static const String editedBy = 'editedBy';

  // Hierarchy fields
  static const String branchId = 'branchId';
  static const String classId = 'classId';
  static const String description = 'description';
}

/// User roles
class UserRoles {
  static const String admin = 'admin';
  static const String faculty = 'faculty';
  static const String student = 'student';
}

/// Attendance statuses
class AttendanceStatus {
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
}

/// System constants
class SystemConstants {
  // Admin credentials
  static const String adminId = 'ADMIN404';
  static const String adminPassword = 'ADMIN9090@@@@';
  
  // Session settings
  static const int defaultSessionRadius = 500; // meters
  static const int sessionCodeLength = 3;
  static const int sessionCodeValidityMinutes = 5;
  static const int attendanceEditWindowHours = 48;
  
  // Location settings
  static const double minimumLocationAccuracy = 50.0; // meters
  static const int locationTimeoutSeconds = 10;
  
  // Security settings
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const bool requireDeviceBinding = true;
  
  // University settings
  static const String universityDomain = '@darshan.ac.in';
  static const String universityName = 'Darshan University';
}
