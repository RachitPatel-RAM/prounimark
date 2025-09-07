# UniMark - Secure Attendance Management System

A production-grade Flutter application for secure attendance management with defense-in-depth security measures to prevent proxy/false attendance.

## 🎯 Features

### Security Features
- **Google SSO** with domain restriction (@darshan.ac.in only)
- **Admin static credentials** (ID: ADMIN404, PWD: ADMIN9090@@@@)
- **Biometric authentication** with PIN fallback
- **Device binding** to prevent multi-device usage
- **GPS location verification** (500m radius)
- **Play Integrity API** integration for device verification
- **App Check** enforcement
- **Server-side HMAC** code verification
- **Comprehensive audit logging**

### User Roles
- **Admin**: Full system management, faculty creation, device binding reset
- **Faculty**: Session creation, attendance monitoring, editing within 48h
- **Student**: Attendance submission with multi-factor verification

### Core Functionality
- **Dynamic hierarchy management** (Branch → Class → Batch)
- **Secure session creation** with 3-digit codes and TTL
- **Real-time attendance tracking**
- **Comprehensive reporting** and analytics
- **Offline-capable** with sync when online

## 🏗️ Architecture

### Frontend (Flutter)
- **Single app** supporting all three roles
- **Red/Black/White theme** with flying-card UI
- **Responsive design** using Sizer
- **Biometric integration** with local_auth
- **Location services** with geolocator
- **Secure storage** for device binding

### Backend (Firebase)
- **Cloud Functions** (TypeScript) for all server-side logic
- **Firestore** for data storage with comprehensive security rules
- **Firebase Auth** with custom claims
- **App Check** for request verification
- **Cloud Logging** for audit trails

### Security Model
- **Defense-in-depth** approach
- **Server-side validation** for all critical operations
- **Client-side security rules** enforcement
- **Rate limiting** and abuse prevention
- **Comprehensive monitoring** and alerting

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.6.0+
- Node.js 18+
- Firebase CLI
- Android Studio / Xcode
- Google Cloud Console access

### 1. Firebase Setup

#### Create Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create new project
firebase projects:create unimark-attendance

# Initialize Firebase in project
firebase init
```

#### Configure Firebase Services
```bash
# Enable required services
firebase use --add unimark-attendance

# Set up App Check
firebase appcheck:apps:register android com.example.unimark
firebase appcheck:apps:register ios com.example.unimark
```

#### Configure Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Google** provider
3. Add authorized domains: `darshan.ac.in`
4. Configure OAuth consent screen

#### Configure Firestore
1. Go to Firebase Console → Firestore Database
2. Create database in production mode
3. Deploy security rules: `firebase deploy --only firestore:rules`
4. Deploy indexes: `firebase deploy --only firestore:indexes`

### 2. Google Cloud Setup

#### Enable APIs
```bash
# Enable required APIs
gcloud services enable playintegrity.googleapis.com
gcloud services enable firebase.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
```

#### Configure Play Integrity
1. Go to Google Cloud Console → Play Integrity API
2. Create credentials for Android app
3. Configure integrity verdict settings
4. Add package name: `com.example.unimark`

### 3. Flutter Setup

#### Install Dependencies
```bash
cd unimark_7853
flutter pub get
```

#### Configure Firebase
1. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Place in appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Configure App Check
```dart
// In main.dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Configure App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  
  runApp(MyApp());
}
```

### 4. Build and Deploy

#### Deploy Cloud Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

#### Build Flutter App
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🔧 Configuration

### Environment Variables
Create `env.json` in project root:
```json
{
  "firebase": {
    "apiKey": "your-api-key",
    "authDomain": "unimark-attendance.firebaseapp.com",
    "projectId": "unimark-attendance",
    "storageBucket": "unimark-attendance.appspot.com",
    "messagingSenderId": "123456789",
    "appId": "1:123456789:android:abcdef123456"
  },
  "admin": {
    "id": "ADMIN404",
    "password": "ADMIN9090@@@@"
  },
  "university": {
    "domain": "@darshan.ac.in",
    "name": "Darshan University"
  }
}
```

### Firebase Functions Config
```bash
# Set admin credentials
firebase functions:config:set admin.id="ADMIN404" admin.password="ADMIN9090@@@@"

# Set Play Integrity key
firebase functions:config:set playintegrity.key="your-play-integrity-key"

# Set seed master key
firebase functions:config:set security.seed_master="your-seed-master-key"
```

## 🧪 Testing

### Unit Tests
```bash
# Run Flutter tests
flutter test

# Run Cloud Functions tests
cd functions
npm test
```

### Integration Tests
```bash
# Start Firebase emulators
firebase emulators:start

# Run integration tests
flutter test integration_test/
```

### Manual Testing
1. **Admin Login**: Use credentials ADMIN404 / ADMIN9090@@@@
2. **Student Registration**: Use @darshan.ac.in email
3. **Faculty Creation**: Admin creates faculty accounts
4. **Session Creation**: Faculty creates sessions
5. **Attendance Submission**: Students submit with biometric/PIN

## 📱 Usage

### Admin Workflow
1. Login with admin credentials
2. Create branches, classes, and batches
3. Create faculty accounts
4. Monitor system activity
5. Reset device bindings when needed
6. View audit logs

### Faculty Workflow
1. Login with Google SSO (@darshan.ac.in)
2. Select branch, class, and batches
3. Create attendance session
4. Share 3-digit code with students
5. Monitor real-time attendance
6. Edit attendance within 48 hours
7. Close session when complete

### Student Workflow
1. Login with Google SSO (@darshan.ac.in)
2. Complete registration (first time only)
3. Set up biometric or PIN
4. View active sessions
5. Enter session code
6. Authenticate with biometric/PIN
7. Submit attendance
8. View attendance history

## 🔒 Security Considerations

### Defense-in-Depth Measures
1. **Identity Verification**: Google SSO + domain restriction
2. **Device Binding**: Prevents multi-device usage
3. **Location Verification**: GPS proximity check (500m)
4. **Biometric/PIN**: Local authentication
5. **Code Verification**: Server-side HMAC validation
6. **Play Integrity**: Device integrity verification
7. **App Check**: Request authenticity
8. **Rate Limiting**: Prevents brute force attacks
9. **Audit Logging**: Comprehensive activity tracking

### Best Practices
- Rotate server seeds periodically
- Monitor audit logs for suspicious activity
- Keep Firebase project secure
- Use HTTPS for all communications
- Implement proper error handling
- Regular security updates

## 🚨 Troubleshooting

### Common Issues

#### Firebase Connection Issues
```bash
# Check Firebase configuration
firebase projects:list
firebase use --add your-project-id

# Verify service account
gcloud auth application-default login
```

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

#### Permission Issues
- Check location permissions in device settings
- Verify biometric enrollment
- Ensure Google Play Services is updated

#### Authentication Issues
- Verify domain restriction (@darshan.ac.in)
- Check OAuth consent screen configuration
- Ensure proper SHA-1 fingerprints

### Debug Mode
```bash
# Enable debug logging
flutter run --debug

# View Firebase logs
firebase functions:log
```

## 📊 Monitoring

### Firebase Console
- **Authentication**: User activity and sign-ins
- **Firestore**: Database usage and performance
- **Functions**: Execution logs and errors
- **App Check**: Verification statistics

### Cloud Logging
- **Audit Logs**: All security events
- **Error Logs**: Application errors
- **Performance Logs**: Function execution times

### Custom Metrics
- Attendance submission rates
- Authentication success/failure rates
- Location verification accuracy
- Device binding statistics

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
name: Deploy UniMark
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - uses: actions/setup-java@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: |
          cd functions && npm install
          flutter pub get
      
      - name: Run tests
        run: |
          flutter test
          cd functions && npm test
      
      - name: Deploy to Firebase
        run: |
          firebase deploy --only functions,firestore
          flutter build apk --release
```

## 📈 Performance Optimization

### Flutter App
- Use `const` constructors where possible
- Implement proper state management
- Optimize image loading and caching
- Use lazy loading for large lists

### Cloud Functions
- Implement proper caching
- Use connection pooling
- Optimize database queries
- Implement rate limiting

### Firestore
- Use composite indexes efficiently
- Implement pagination for large datasets
- Use offline persistence
- Optimize security rules

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Style
- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comprehensive comments
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the troubleshooting section
- Review Firebase documentation

## 🔮 Future Enhancements

- **Offline Mode**: Full offline capability
- **Push Notifications**: Real-time updates
- **Analytics Dashboard**: Advanced reporting
- **Multi-language Support**: Internationalization
- **API Integration**: Third-party system integration
- **Advanced Security**: Additional verification methods

---

**UniMark** - Secure, Reliable, Production-Ready Attendance Management