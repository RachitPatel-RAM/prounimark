# UniMark QA Checklist

## Pre-Release Testing Checklist

### 🔐 Authentication & Security

#### Google SSO Testing
- [ ] **Domain Restriction**: Only @darshan.ac.in emails can sign in
- [ ] **Invalid Domain**: Non-darshan.ac.in emails are rejected with proper error message
- [ ] **OAuth Flow**: Complete Google sign-in flow works correctly
- [ ] **Token Refresh**: Authentication tokens refresh properly
- [ ] **Sign Out**: User can sign out and session is cleared

#### Admin Authentication
- [ ] **Valid Credentials**: ADMIN404 / ADMIN9090@@@@ login works
- [ ] **Invalid Credentials**: Wrong admin credentials are rejected
- [ ] **Admin Privileges**: Admin has access to all admin functions
- [ ] **Custom Token**: Admin receives proper custom token

#### Student Registration
- [ ] **First Time User**: New users are prompted for registration
- [ ] **Enrollment Validation**: Duplicate enrollment numbers are rejected
- [ ] **Hierarchy Validation**: Branch/Class/Batch validation works
- [ ] **PIN Setup**: PIN setup works for users without biometrics
- [ ] **Device Binding**: Device binding is created on first registration

#### Biometric Authentication
- [ ] **Biometric Available**: App detects available biometric types
- [ ] **Fingerprint**: Fingerprint authentication works
- [ ] **Face ID**: Face ID authentication works (iOS)
- [ ] **PIN Fallback**: PIN authentication works when biometrics unavailable
- [ ] **Authentication Failure**: Proper error handling for failed authentication
- [ ] **Multiple Attempts**: Rate limiting works for failed attempts

### 📍 Location Services

#### GPS Verification
- [ ] **Location Permission**: App requests and handles location permissions
- [ ] **Location Accuracy**: Location accuracy validation works
- [ ] **Distance Calculation**: Distance to session location is calculated correctly
- [ ] **Radius Check**: 500m radius validation works
- [ ] **Location Too Far**: Proper error when outside radius
- [ ] **Location Disabled**: Proper handling when location services disabled
- [ ] **Permission Denied**: Proper handling when location permission denied

### 🎯 Session Management

#### Faculty Session Creation
- [ ] **Session Creation**: Faculty can create sessions successfully
- [ ] **Code Generation**: 3-digit session codes are generated
- [ ] **TTL Setting**: Session TTL (5 minutes default) works
- [ ] **Location Recording**: Faculty location is recorded accurately
- [ ] **Batch Selection**: Multi-batch selection works
- [ ] **Session Validation**: Invalid session data is rejected

#### Student Session Access
- [ ] **Active Sessions**: Students see only their eligible active sessions
- [ ] **Session Filtering**: Sessions filtered by branch/class/batch
- [ ] **Expired Sessions**: Expired sessions are not shown
- [ ] **Session Details**: Session information displays correctly

### ✅ Attendance Submission

#### Complete Attendance Flow
- [ ] **Session Code**: 3-digit code entry works
- [ ] **Code Validation**: Invalid codes are rejected
- [ ] **Location Check**: Location verification works
- [ ] **Biometric/PIN**: Authentication method works
- [ ] **Device Binding**: Device binding verification works
- [ ] **Duplicate Prevention**: Duplicate submissions are prevented
- [ ] **Success Response**: Successful submission shows confirmation
- [ ] **Error Handling**: All error cases show appropriate messages

#### Security Verification
- [ ] **HMAC Validation**: Server-side code verification works
- [ ] **Device Binding**: Device binding prevents multi-device usage
- [ ] **Location Spoofing**: Location spoofing attempts are detected
- [ ] **Code Brute Force**: Rate limiting prevents code brute force
- [ ] **Play Integrity**: Play Integrity verification works (Android)

### 👥 User Management

#### Admin Functions
- [ ] **Branch Management**: Create, read, update, delete branches
- [ ] **Class Management**: Create, read, update, delete classes
- [ ] **Batch Management**: Create, read, update, delete batches
- [ ] **Faculty Creation**: Admin can create faculty accounts
- [ ] **User List**: Admin can view all users
- [ ] **Device Binding Reset**: Admin can reset device bindings
- [ ] **Audit Logs**: Admin can view audit logs

#### Faculty Functions
- [ ] **Session Management**: Create, monitor, close sessions
- [ ] **Attendance Viewing**: View session attendance
- [ ] **Attendance Editing**: Edit attendance within 48 hours
- [ ] **Session Statistics**: View session statistics
- [ ] **Student List**: View eligible students

#### Student Functions
- [ ] **Profile View**: View own profile information
- [ ] **Attendance History**: View attendance history
- [ ] **Statistics**: View attendance statistics
- [ ] **Session List**: View active sessions

### 🔒 Security Testing

#### Firestore Security Rules
- [ ] **User Access**: Users can only access their own data
- [ ] **Admin Access**: Admin can access all data
- [ ] **Faculty Access**: Faculty can access relevant data only
- [ ] **Attendance Protection**: Attendance can only be written by Cloud Functions
- [ ] **Server Seeds**: Server seeds are not accessible to clients
- [ ] **Audit Logs**: Audit logs are read-only for clients

#### Cloud Functions Security
- [ ] **Authentication Required**: All functions require authentication
- [ ] **Role Validation**: Functions validate user roles
- [ ] **Input Validation**: All inputs are validated
- [ ] **Rate Limiting**: Rate limiting works
- [ ] **Error Handling**: Proper error responses
- [ ] **Audit Logging**: All actions are logged

### 📱 UI/UX Testing

#### Theme & Design
- [ ] **Red/Black/White Theme**: Theme is applied consistently
- [ ] **Flying Card UI**: Card animations work smoothly
- [ ] **Responsive Design**: App works on different screen sizes
- [ ] **Accessibility**: App is accessible to users with disabilities
- [ ] **Loading States**: Loading indicators work properly
- [ ] **Error States**: Error messages are clear and helpful

#### Navigation
- [ ] **Role-based Navigation**: Navigation changes based on user role
- [ ] **Back Navigation**: Back button works correctly
- [ ] **Deep Linking**: Deep links work (if implemented)
- [ ] **State Persistence**: App state persists across navigation

### 🌐 Network & Performance

#### Connectivity
- [ ] **Online Mode**: App works when online
- [ ] **Offline Mode**: App handles offline gracefully
- [ ] **Sync**: Data syncs when connection restored
- [ ] **Network Errors**: Network errors are handled properly

#### Performance
- [ ] **App Launch**: App launches quickly
- [ ] **Screen Transitions**: Smooth screen transitions
- [ ] **Data Loading**: Data loads efficiently
- [ ] **Memory Usage**: Memory usage is reasonable
- [ ] **Battery Usage**: Battery usage is optimized

### 🔧 Device Compatibility

#### Android Testing
- [ ] **API Level 21+**: Works on Android 5.0+
- [ ] **Different Screen Sizes**: Works on phones and tablets
- [ ] **Biometric Support**: Works with/without biometrics
- [ ] **Location Services**: Works with different location providers
- [ ] **Play Services**: Works with/without Google Play Services

#### iOS Testing
- [ ] **iOS 12+**: Works on iOS 12+
- [ ] **Different Devices**: Works on iPhone and iPad
- [ ] **Face ID/Touch ID**: Works with biometric authentication
- [ ] **Location Services**: Works with iOS location services

### 🧪 Edge Cases

#### Error Scenarios
- [ ] **Invalid Input**: Handles invalid user input
- [ ] **Network Timeout**: Handles network timeouts
- [ ] **Server Errors**: Handles server errors gracefully
- [ ] **Permission Denied**: Handles permission denials
- [ ] **Storage Full**: Handles storage full scenarios

#### Boundary Conditions
- [ ] **Empty Data**: Handles empty data sets
- [ ] **Large Data**: Handles large data sets
- [ ] **Concurrent Users**: Handles multiple concurrent users
- [ ] **Session Expiry**: Handles session expiry during use
- [ ] **Device Rotation**: Handles device rotation

### 📊 Data Integrity

#### Data Validation
- [ ] **Input Sanitization**: All inputs are sanitized
- [ ] **Data Consistency**: Data remains consistent
- [ ] **Transaction Integrity**: Database transactions work
- [ ] **Backup/Restore**: Data backup and restore works

#### Audit Trail
- [ ] **All Actions Logged**: All user actions are logged
- [ ] **Log Accuracy**: Logs contain accurate information
- [ ] **Log Security**: Logs are secure and tamper-proof
- [ ] **Log Retention**: Logs are retained appropriately

## Test Accounts

### Admin Account
- **ID**: ADMIN404
- **Password**: ADMIN9090@@@@
- **Permissions**: Full system access

### Faculty Test Accounts
- **Email**: faculty1@darshan.ac.in
- **Email**: faculty2@darshan.ac.in
- **Permissions**: Session creation, attendance management

### Student Test Accounts
- **Email**: student1@darshan.ac.in
- **Email**: student2@darshan.ac.in
- **Email**: student3@darshan.ac.in
- **Permissions**: Attendance submission, profile viewing

## Test Data

### Branches
- Computer Science (CS)
- Information Technology (IT)
- Electronics & Communication (EC)
- Mechanical Engineering (ME)

### Classes
- CS-A, CS-B, CS-C
- IT-A, IT-B
- EC-A, EC-B
- ME-A, ME-B

### Batches
- 2024, 2023, 2022, 2021

## Performance Benchmarks

### Response Times
- [ ] **App Launch**: < 3 seconds
- [ ] **Login**: < 2 seconds
- [ ] **Session Creation**: < 1 second
- [ ] **Attendance Submission**: < 3 seconds
- [ ] **Data Loading**: < 1 second

### Resource Usage
- [ ] **Memory Usage**: < 100MB
- [ ] **Battery Drain**: < 5% per hour
- [ ] **Data Usage**: < 1MB per session
- [ ] **Storage**: < 50MB total

## Security Benchmarks

### Authentication
- [ ] **Login Success Rate**: > 99%
- [ ] **False Positive Rate**: < 0.1%
- [ ] **Session Timeout**: 30 minutes
- [ ] **Password Policy**: Enforced

### Data Protection
- [ ] **Encryption**: All data encrypted in transit and at rest
- [ ] **Access Control**: Role-based access enforced
- [ ] **Audit Coverage**: 100% of critical actions logged
- [ ] **Data Retention**: Compliant with policy

## Sign-off

### QA Lead
- [ ] **Name**: ________________
- [ ] **Date**: ________________
- [ ] **Signature**: ________________

### Development Lead
- [ ] **Name**: ________________
- [ ] **Date**: ________________
- [ ] **Signature**: ________________

### Security Lead
- [ ] **Name**: ________________
- [ ] **Date**: ________________
- [ ] **Signature**: ________________

---

**Note**: This checklist should be completed before any production release. All items must be checked off and signed by the respective leads.
