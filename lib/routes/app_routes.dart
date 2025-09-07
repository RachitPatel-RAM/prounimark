import 'package:flutter/material.dart';
import '../presentation/faculty_dashboard/faculty_dashboard.dart';
import '../presentation/create_attendance_session_screen/create_attendance_session_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/student_dashboard/student_dashboard.dart';
import '../presentation/student_registration_screen/student_registration_screen.dart';
import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/attendance_history_screen/attendance_history_screen.dart';
import '../presentation/mark_attendance_screen/mark_attendance_screen.dart';
import '../presentation/profile_management_screen/profile_management_screen.dart';
import '../presentation/manage_hierarchy_screen/manage_hierarchy_screen.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String facultyDashboard = '/faculty-dashboard';
  static const String createAttendanceSession =
      '/create-attendance-session-screen';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String studentDashboard = '/student-dashboard';
  static const String studentRegistration = '/student-registration-screen';
  static const String adminDashboard = '/admin-dashboard';
  static const String attendanceHistory = '/attendance-history';
  static const String markAttendance = '/mark-attendance';
  static const String profileManagement = '/profile-management';
  static const String manageHierarchy = '/manage-hierarchy';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    facultyDashboard: (context) => const FacultyDashboard(),
    createAttendanceSession: (context) => const CreateAttendanceSessionScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentDashboard: (context) => const StudentDashboard(),
    studentRegistration: (context) => const StudentRegistrationScreen(),
    adminDashboard: (context) => AdminDashboardScreen(
      currentUser: UserModel(
        id: 'admin',
        name: 'Admin User',
        email: 'admin@unimark.com',
        role: UserRole.admin,
        enrollmentNumber: 'ADMIN001',
        branch: 'Administration',
        className: 'Admin',
        batch: '2024',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
    attendanceHistory: (context) => AttendanceHistoryScreen(
      currentUser: UserModel(
        id: 'temp_user',
        name: 'Current User',
        email: 'user@unimark.com',
        role: UserRole.student,
        enrollmentNumber: 'STU001',
        branch: 'Computer Science',
        className: 'CS-A',
        batch: '2024',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
    markAttendance: (context) => MarkAttendanceScreen(
      session: SessionModel(
        id: 'temp_session',
        facultyId: 'faculty_001',
        facultyName: 'Sample Faculty',
        branch: 'Computer Science',
        className: 'CS-A',
        batches: ['2024'],
        subject: 'Sample Subject',
        location: LocationData(latitude: 0.0, longitude: 0.0),
        radius: 100,
        code: 'SAMPLE123',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      currentUser: UserModel(
        id: 'temp_user',
        name: 'Current User',
        email: 'user@unimark.com',
        role: UserRole.student,
        enrollmentNumber: 'STU001',
        branch: 'Computer Science',
        className: 'CS-A',
        batch: '2024',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ),
    profileManagement: (context) => const ProfileManagementScreen(),
    manageHierarchy: (context) => const ManageHierarchyScreen(),
    // TODO: Add your other routes here
  };
}
