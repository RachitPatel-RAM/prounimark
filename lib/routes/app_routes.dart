import 'package:flutter/material.dart';
import '../presentation/faculty_dashboard/faculty_dashboard_screen.dart';
import '../presentation/faculty_login_screen/faculty_login_screen.dart';
import '../presentation/faculty_password_reset_screen/faculty_password_reset_screen.dart';
import '../presentation/create_attendance_session_screen/create_attendance_session_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/student_dashboard/student_dashboard.dart';
import '../presentation/student_registration_screen/student_registration_screen.dart';
import '../presentation/admin_dashboard/admin_dashboard_screen.dart';
import '../presentation/attendance_history_screen/attendance_history_screen.dart';
import '../presentation/mark_attendance_screen/mark_attendance_screen.dart';
import '../presentation/profile_management_screen/profile_management_screen.dart';
import '../presentation/manage_hierarchy_screen/manage_hierarchy_screen.dart';
import '../presentation/location_validation_screen/location_validation_screen.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../services/auth_service.dart';

class AppRoutes {
  static const String initial = '/';
  static const String facultyDashboard = '/faculty-dashboard';
  static const String facultyLogin = '/faculty-login';
  static const String facultyPasswordReset = '/faculty-password-reset';
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
  static const String locationValidation = '/location-validation';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    facultyDashboard: (context) => _buildFacultyDashboard(context),
    facultyLogin: (context) => const FacultyLoginScreen(),
    facultyPasswordReset: (context) => const FacultyPasswordResetScreen(),
    createAttendanceSession: (context) => const CreateAttendanceSessionScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentDashboard: (context) => const StudentDashboard(),
    studentRegistration: (context) => const StudentRegistrationScreen(),
    adminDashboard: (context) => _buildAdminDashboard(context),
    attendanceHistory: (context) => _buildAttendanceHistory(context),
    markAttendance: (context) => _buildMarkAttendance(context),
    profileManagement: (context) => _buildProfileManagement(context),
    manageHierarchy: (context) => _buildManageHierarchy(context),
    locationValidation: (context) => const LocationValidationScreen(),
  };

  static Widget _buildFacultyDashboard(BuildContext context) {
    final authService = AuthService();
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user == null || user.role != UserRole.faculty) {
          return const FacultyLoginScreen();
        }
        
        return const FacultyDashboardScreen();
      },
    );
  }

  static Widget _buildAdminDashboard(BuildContext context) {
    final authService = AuthService();
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user == null || user.role != UserRole.admin) {
          return const LoginScreen();
        }
        
        return const AdminDashboardScreen();
      },
    );
  }

  static Widget _buildAttendanceHistory(BuildContext context) {
    final authService = AuthService();
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        
        return AttendanceHistoryScreen(currentUser: user);
      },
    );
  }

  static Widget _buildMarkAttendance(BuildContext context) {
    // This should be called with session data from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('session') || !args.containsKey('user')) {
      return const LoginScreen();
    }
    
    final session = args['session'] as SessionModel;
    final user = args['user'] as UserModel;
    
    return MarkAttendanceScreen(
      session: session,
      currentUser: user,
    );
  }

  static Widget _buildProfileManagement(BuildContext context) {
    final authService = AuthService();
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        
        return ProfileManagementScreen(currentUser: user);
      },
    );
  }

  static Widget _buildManageHierarchy(BuildContext context) {
    final authService = AuthService();
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUserModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user == null || user.role != UserRole.admin) {
          return const LoginScreen();
        }
        
        return ManageHierarchyScreen(currentUser: user);
      },
    );
  }
}
