import 'package:flutter/material.dart';
import '../presentation/faculty_dashboard/faculty_dashboard.dart';
import '../presentation/create_attendance_session_screen/create_attendance_session_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/student_dashboard/student_dashboard.dart';
import '../presentation/student_registration_screen/student_registration_screen.dart';

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

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    facultyDashboard: (context) => const FacultyDashboard(),
    createAttendanceSession: (context) => const CreateAttendanceSessionScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentDashboard: (context) => const StudentDashboard(),
    studentRegistration: (context) => const StudentRegistrationScreen(),
    // TODO: Add your other routes here
  };
}
