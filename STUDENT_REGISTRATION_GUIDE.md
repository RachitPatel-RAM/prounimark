# Student Registration System - UniMark

## Overview

The Student Registration System for UniMark is a comprehensive, secure, and user-friendly solution that handles the complete student onboarding process. It integrates Google Sign-In with domain restrictions, dynamic academic hierarchy selection, location-based security, and biometric/PIN authentication.

## Features

### 🔐 Authentication & Security
- **Google Sign-In Integration**: Students must sign in using their official university email (@darshan.ac.in)
- **Domain Restriction**: Only @darshan.ac.in emails are allowed
- **Device Binding**: Each student account is bound to a single device for security
- **Biometric Authentication**: Fingerprint/Face ID support for secure attendance marking
- **PIN Fallback**: 4-digit PIN system for devices without biometric support
- **Location Verification**: GPS-based attendance verification within 500m radius

### 📝 Registration Process
The registration process consists of 5 steps:

1. **Personal Information**
   - Full name (auto-filled from Google account, editable)
   - Enrollment number (unique, 6+ characters, alphanumeric)
   - Enrollment number confirmation (no copy-paste allowed)

2. **Academic Details**
   - Branch selection (dynamically loaded from Firestore)
   - Class selection (filtered by selected branch)
   - Batch selection (filtered by selected class)
   - All selections are locked after registration

3. **Location Access**
   - GPS permission request
   - Current location capture
   - Location accuracy validation

4. **Security Setup**
   - Biometric authentication setup (if available)
   - PIN setup (4-digit, if biometric not available)
   - Security method testing

5. **Review & Complete**
   - Information review
   - Final registration submission
   - Success confirmation

### 🎨 User Interface
- **Flying Card Design**: Smooth animations with floating card effects
- **Premium Theme**: Red (#D32F2F), Black (#000000), White (#FFFFFF) color scheme
- **Responsive Design**: Optimized for mobile devices using Sizer package
- **Professional Styling**: Clean, minimal, and academic-focused design
- **Smooth Transitions**: Fade and slide animations throughout the flow

## Technical Implementation

### Architecture
```
lib/
├── services/
│   ├── auth_service.dart              # Authentication & user management
│   ├── hierarchy_service.dart         # Academic hierarchy management
│   ├── biometric_service.dart         # Biometric & PIN handling
│   └── location_validation_service.dart # GPS & location services
├── models/
│   ├── user_model.dart               # User data model
│   └── hierarchy_model.dart          # Academic hierarchy models
├── presentation/
│   └── student_registration_screen/
│       ├── student_registration_screen.dart
│       └── widgets/
│           ├── flying_card_widget.dart
│           ├── pin_input_widget.dart
│           ├── biometric_setup_widget.dart
│           ├── registration_form_widget.dart
│           └── hierarchical_dropdown_widget.dart
└── config/
    └── firebase_config.dart          # Firebase configuration
```

### Key Services

#### AuthService
- Google Sign-In with domain validation
- Student registration completion
- Device binding management
- PIN hashing and verification

#### HierarchyService
- Dynamic loading of branches, classes, and batches
- Hierarchical data management
- Admin-only CRUD operations

#### BiometricService
- Biometric availability checking
- Authentication testing
- PIN validation and hashing
- Security method management

#### LocationValidationService
- GPS permission handling
- Location accuracy validation
- Settings navigation

### Data Models

#### UserModel
```dart
class UserModel {
  final String id;                    // Firebase UID
  final String name;                  // Full name
  final String email;                 // @darshan.ac.in email
  final UserRole role;                // student/faculty/admin
  final String enrollmentNo;          // Unique enrollment number
  final String branch;                // Selected branch ID
  final String classId;               // Selected class ID
  final String batchId;               // Selected batch ID
  final DeviceBinding? deviceBinding; // Device binding info
  final String? pinHash;              // Hashed PIN (if no biometric)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}
```

#### Hierarchy Models
```dart
class BranchModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}

class ClassModel {
  final String id;
  final String branchId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
}

class BatchModel {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
}
```

## Firestore Schema

### Collections

#### users
```json
{
  "id": "firebase_uid",
  "name": "Student Name",
  "email": "student@darshan.ac.in",
  "role": "student",
  "enrollmentNo": "EN123456",
  "branch": "branch_id",
  "classId": "class_id",
  "batchId": "batch_id",
  "deviceBinding": {
    "instIdHash": "hashed_device_id",
    "platform": "android/ios",
    "boundAt": "timestamp"
  },
  "pinHash": "hashed_pin",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true
}
```

#### branches
```json
{
  "id": "branch_id",
  "name": "Computer Engineering",
  "description": "CE Department",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true
}
```

#### classes
```json
{
  "id": "class_id",
  "branchId": "branch_id",
  "name": "Semester 1",
  "description": "First Semester",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true
}
```

#### batches
```json
{
  "id": "batch_id",
  "classId": "class_id",
  "name": "Batch A",
  "description": "First Batch",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true
}
```

#### device_bindings
```json
{
  "id": "user_id",
  "userId": "firebase_uid",
  "deviceUuid": "device_uuid",
  "instIdHash": "hashed_device_id",
  "platform": "android/ios",
  "boundAt": "timestamp",
  "isActive": true
}
```

## Security Features

### Authentication Security
- **Domain Restriction**: Only @darshan.ac.in emails allowed
- **Google OAuth**: Secure authentication via Google
- **Device Binding**: One account per device
- **Session Management**: Secure session handling

### Data Security
- **PIN Hashing**: SHA-256 hashing for PIN storage
- **Device Fingerprinting**: Unique device identification
- **Location Verification**: GPS-based attendance validation
- **Anti-Proxy Measures**: Device integrity checks

### Firestore Security Rules
- **Role-based Access**: Different permissions for students, faculty, and admins
- **Data Validation**: Comprehensive input validation
- **Location Verification**: Distance-based attendance validation
- **Session Validation**: Time and code-based session verification

## Usage Instructions

### For Students

1. **Initial Setup**
   - Download and install the UniMark app
   - Ensure you have a @darshan.ac.in email account
   - Enable location services on your device

2. **Registration Process**
   - Open the app and select "Student" role
   - Tap "Sign in with Google"
   - Use your @darshan.ac.in email
   - Complete the 5-step registration process
   - Set up biometric authentication or PIN
   - Review and submit your information

3. **Post-Registration**
   - Your account is now active
   - You can mark attendance for your classes
   - Your academic details are locked (admin can change if needed)
   - Device binding is active for security

### For Administrators

1. **Hierarchy Management**
   - Add/edit branches, classes, and batches
   - Manage user accounts
   - View registration statistics
   - Handle device binding issues

2. **Security Management**
   - Monitor device bindings
   - Reset device bindings if needed
   - View audit logs
   - Manage system settings

## Error Handling

### Common Issues

1. **Domain Restriction Error**
   - Error: "Only official university email allowed"
   - Solution: Use @darshan.ac.in email address

2. **Enrollment Number Already Exists**
   - Error: "Enrollment number already registered"
   - Solution: Contact administrator or use different enrollment number

3. **Location Access Denied**
   - Error: "Location access is required"
   - Solution: Enable location services in device settings

4. **Biometric Not Available**
   - Error: "Biometric authentication not available"
   - Solution: Set up PIN instead or enable biometrics in device settings

5. **Device Binding Error**
   - Error: "Device already bound to another account"
   - Solution: Contact administrator to reset device binding

## Testing

### Test Scenarios

1. **Registration Flow**
   - Test with valid @darshan.ac.in email
   - Test with invalid email domain
   - Test enrollment number validation
   - Test hierarchy selection
   - Test location access
   - Test biometric/PIN setup

2. **Security Features**
   - Test device binding
   - Test PIN hashing
   - Test biometric authentication
   - Test location verification
   - Test session validation

3. **Error Handling**
   - Test network connectivity issues
   - Test invalid input handling
   - Test permission denials
   - Test Firebase errors

## Deployment

### Prerequisites
- Firebase project setup
- Google Sign-In configuration
- Firestore database
- Android/iOS app configuration

### Steps
1. Configure Firebase project
2. Set up Google Sign-In
3. Deploy Firestore rules
4. Configure app signing
5. Test on devices
6. Deploy to app stores

## Maintenance

### Regular Tasks
- Monitor registration statistics
- Review audit logs
- Update hierarchy data
- Handle user issues
- Security updates

### Backup & Recovery
- Regular Firestore backups
- User data export
- Configuration backups
- Disaster recovery procedures

## Support

### Contact Information
- Technical Support: [support@darshan.ac.in]
- Admin Support: [admin@darshan.ac.in]
- Emergency: [emergency@darshan.ac.in]

### Documentation
- API Documentation: [link]
- User Manual: [link]
- Admin Guide: [link]
- Troubleshooting: [link]

---

**Version**: 1.0.0  
**Last Updated**: [Current Date]  
**Maintained By**: UniMark Development Team
