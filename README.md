# UniMark - Secure Attendance Management System

A comprehensive Flutter application for secure attendance management with anti-proxy measures, GPS-based location verification, and role-based access control.

## Features

### 🔐 Authentication & Roles
- **Students**: Register with university email domain (@darshan.ac.in)
- **Faculty**: Created by admin only, no self-registration
- **Admin**: Static login (ID: ADMIN404, Password: ADMIN9090@@@@)

### 📚 Academic Hierarchy Management
- **Branches**: Admin-managed academic branches
- **Classes**: Classes within branches
- **Batches**: Batches within classes
- **Student Registration**: Dropdown-based selection, locked after signup

### 🎓 Attendance System
- **3-digit random codes** for each session
- **GPS location verification** (500m radius)
- **Real-time attendance tracking**
- **Anti-proxy measures** with device binding
- **48-hour edit window** for faculty

### 🛡 Security Features
- **Location-based verification**
- **Device ID binding** (one device per student)
- **Firebase security rules**
- **Session code validation**
- **Audit logging**

## Screens Implemented

### ✅ Completed Screens
1. **Login Screen** - Role-based authentication
2. **Student Registration** - With hierarchical dropdowns
3. **Student Dashboard** - View active sessions
4. **Faculty Dashboard** - Create and manage sessions
5. **Create Attendance Session** - Faculty session creation
6. **Mark Attendance Screen** - Student attendance submission
7. **Attendance History Screen** - Student attendance records
8. **Admin Dashboard** - Complete system management
9. **Manage Hierarchy Screen** - Branch/Class/Batch management
10. **Profile Management Screen** - User profile management

## Technical Stack

- **Frontend**: Flutter 3.6.0+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Location**: Geolocator with GPS verification
- **UI**: Material 3 with custom red/black/white theme
- **State Management**: StatefulWidget with Firebase streams
- **Security**: Firebase Security Rules + custom validation

## Setup Instructions

### 1. Prerequisites
- Flutter SDK 3.6.0 or higher
- Android Studio / VS Code
- Firebase project setup
- Android device/emulator for testing

### 2. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password
3. Create Firestore database
4. Download `google-services.json` and place in `android/app/`
5. Deploy Firestore security rules from `firestore.rules`

### 3. Installation

```bash
# Clone the repository
git clone <repository-url>
cd unimark_7853

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 4. Build APK

```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## Project Structure

```
lib/
├── config/
│   └── firebase_config.dart          # Firebase configuration
├── core/
│   └── app_export.dart               # Core exports
├── models/
│   ├── user_model.dart               # User data model
│   ├── session_model.dart            # Session data model
│   ├── attendance_model.dart         # Attendance data model
│   └── hierarchy_model.dart          # Hierarchy data models
├── services/
│   ├── firebase_service.dart         # Firebase operations
│   └── location_service.dart         # Location services
├── presentation/
│   ├── login_screen/                 # Authentication
│   ├── student_registration_screen/  # Student signup
│   ├── student_dashboard/            # Student main screen
│   ├── faculty_dashboard/            # Faculty main screen
│   ├── create_attendance_session_screen/ # Session creation
│   ├── mark_attendance_screen/       # Attendance submission
│   ├── attendance_history_screen/    # Attendance records
│   ├── admin_dashboard_screen/       # Admin management
│   ├── manage_hierarchy_screen/      # Hierarchy management
│   └── profile_management_screen/    # Profile management
├── routes/
│   └── app_routes.dart               # App routing
├── theme/
│   └── app_theme.dart                # App theming
├── widgets/
│   └── custom_*.dart                 # Reusable widgets
└── main.dart                         # App entry point
```

## Usage Guide

### For Students
1. Register with university email (@darshan.ac.in)
2. Select branch, class, and batch during registration
3. View active attendance sessions
4. Mark attendance using 3-digit code and location verification
5. View attendance history and statistics

### For Faculty
1. Login with admin-created credentials
2. Create attendance sessions with location and code
3. Monitor real-time attendance
4. Edit attendance within 48-hour window
5. View attendance reports

### For Admins
1. Login with static credentials (ADMIN404/ADMIN9090@@@@)
2. Manage branches, classes, and batches
3. Create faculty accounts
4. View all system data and reports
5. Override attendance records

## Security Features

### Anti-Proxy Measures
- **GPS Location Verification**: Students must be within 500m of session
- **Device Binding**: One device per student account
- **Session Codes**: Time-limited 3-digit codes
- **Email Domain Validation**: Only @darshan.ac.in emails allowed
- **Firebase Security Rules**: Comprehensive access control

### Data Protection
- **Encrypted Storage**: All data encrypted in Firestore
- **Role-based Access**: Users can only access their data
- **Audit Logging**: All actions logged for security
- **Session Management**: Secure session handling

## Configuration

### Environment Variables
Create `env.json` in the root directory:
```json
{
  "firebase_api_key": "your_api_key",
  "firebase_project_id": "your_project_id",
  "university_domain": "@darshan.ac.in",
  "default_radius": 500
}
```

### Firebase Security Rules
Deploy the provided `firestore.rules` to your Firebase project for proper security.

## Testing

### Test Credentials
- **Admin**: ID: ADMIN404, Password: ADMIN9090@@@@
- **Faculty**: Created by admin
- **Students**: Register with @darshan.ac.in email

### Test Scenarios
1. Student registration and login
2. Faculty session creation
3. Attendance marking with location
4. Admin hierarchy management
5. Security rule validation

## Troubleshooting

### Common Issues
1. **Location not working**: Enable location permissions
2. **Firebase connection**: Check google-services.json
3. **Build errors**: Run `flutter clean && flutter pub get`
4. **Permission denied**: Check Firestore security rules

### Debug Mode
Enable debug logging by setting `debugMode: true` in Firebase config.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: support@unimark.edu
- Documentation: [Project Wiki]
- Issues: [GitHub Issues]

## Version History

- **v1.0.0**: Initial release with all core features
  - Complete attendance management system
  - Role-based authentication
  - GPS-based location verification
  - Admin dashboard and hierarchy management
  - Security rules and anti-proxy measures