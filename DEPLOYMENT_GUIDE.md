# UniMark Deployment Guide

## 🚀 Production Deployment Checklist

### Pre-Deployment Setup

#### 1. Firebase Project Setup
```bash
# Create Firebase project
firebase projects:create unimark-attendance-prod

# Initialize Firebase in project
firebase init
# Select: Firestore, Functions, Hosting, Storage
# Choose production project
# Use existing firestore.rules and firestore.indexes.json
# Use existing functions directory
# Configure hosting (optional)
```

#### 2. Google Cloud Console Setup
```bash
# Enable required APIs
gcloud services enable playintegrity.googleapis.com
gcloud services enable firebase.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable firestore.googleapis.com
gcloud services enable firebaseappcheck.googleapis.com
```

#### 3. Authentication Configuration
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Google** provider
3. Add authorized domains:
   - `darshan.ac.in`
   - `unimark-attendance-prod.firebaseapp.com`
4. Configure OAuth consent screen
5. Add test users for initial setup

#### 4. Firestore Configuration
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

#### 5. Cloud Functions Configuration
```bash
# Set environment variables
firebase functions:config:set admin.id="ADMIN404" admin.password="ADMIN9090@@@@" --project unimark-attendance-prod
firebase functions:config:set university.domain="@darshan.ac.in" university.name="Darshan University" --project unimark-attendance-prod
firebase functions:config:set security.default_radius="500" security.default_ttl="300" security.edit_window="172800" --project unimark-attendance-prod

# Deploy functions
firebase deploy --only functions --project unimark-attendance-prod
```

#### 6. App Check Configuration
```bash
# Register Android app
firebase appcheck:apps:register android com.example.unimark --project unimark-attendance-prod

# Register iOS app
firebase appcheck:apps:register ios com.example.unimark --project unimark-attendance-prod
```

### Flutter App Configuration

#### 1. Update Firebase Configuration
1. Download production `google-services.json` and `GoogleService-Info.plist`
2. Replace files in:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

#### 2. Update App Configuration
```dart
// In lib/config/firebase_config.dart
class FirebaseConfig {
  static const String projectId = 'unimark-attendance-prod';
  static const String apiKey = 'your-production-api-key';
  // ... other production config
}
```

#### 3. Build Production APK
```bash
# Clean and build
flutter clean
flutter pub get

# Build release APK
flutter build apk --release --target-platform android-arm64

# Build release AAB (for Play Store)
flutter build appbundle --release
```

#### 4. Build Production iOS
```bash
# Build iOS release
flutter build ios --release

# Archive for App Store
# Use Xcode to archive and upload to App Store Connect
```

### Security Configuration

#### 1. Play Integrity API Setup
1. Go to Google Cloud Console → Play Integrity API
2. Create credentials for Android app
3. Configure integrity verdict settings
4. Add package name: `com.example.unimark`
5. Update Cloud Functions with Play Integrity key

#### 2. App Check Setup
1. Go to Firebase Console → App Check
2. Configure Play Integrity for Android
3. Configure App Attest for iOS
4. Enable enforcement for Firestore and Functions

#### 3. Security Rules Verification
```bash
# Test security rules
firebase emulators:start --only firestore
# Run security rule tests
firebase emulators:exec --only firestore "npm test"
```

### Data Seeding

#### 1. Seed Initial Data
```bash
# Run data seeding script
cd scripts
node seed_data.js
```

#### 2. Verify Data
1. Check Firebase Console → Firestore
2. Verify all collections are created
3. Verify sample data is present
4. Test with sample accounts

### Monitoring Setup

#### 1. Cloud Logging
1. Go to Google Cloud Console → Logging
2. Set up log-based metrics
3. Configure alerts for errors
4. Set up log retention policies

#### 2. Firebase Performance
1. Enable Firebase Performance Monitoring
2. Configure custom traces
3. Set up performance alerts

#### 3. Crashlytics
1. Enable Firebase Crashlytics
2. Configure crash reporting
3. Set up crash alerts

### Testing

#### 1. Smoke Tests
```bash
# Run automated tests
flutter test
cd functions && npm test

# Run integration tests
flutter test integration_test/
```

#### 2. Manual Testing
1. Test admin login with credentials
2. Test student registration flow
3. Test faculty session creation
4. Test attendance submission
5. Test all error scenarios

#### 3. Load Testing
1. Test with multiple concurrent users
2. Test session creation under load
3. Test attendance submission under load
4. Monitor performance metrics

### Go-Live Checklist

#### Pre-Launch
- [ ] All tests passing
- [ ] Security rules deployed
- [ ] Cloud Functions deployed
- [ ] App Check configured
- [ ] Play Integrity configured
- [ ] Sample data seeded
- [ ] Monitoring configured
- [ ] Backup strategy in place

#### Launch Day
- [ ] Deploy to production
- [ ] Verify all services working
- [ ] Test with real users
- [ ] Monitor logs and metrics
- [ ] Be ready to rollback if needed

#### Post-Launch
- [ ] Monitor for 24 hours
- [ ] Check error rates
- [ ] Verify user feedback
- [ ] Update documentation
- [ ] Plan maintenance schedule

## 🔧 Maintenance

### Regular Tasks

#### Daily
- [ ] Check error logs
- [ ] Monitor performance metrics
- [ ] Verify backup completion
- [ ] Check user feedback

#### Weekly
- [ ] Review audit logs
- [ ] Check security alerts
- [ ] Update dependencies
- [ ] Performance optimization

#### Monthly
- [ ] Security audit
- [ ] Data cleanup
- [ ] Capacity planning
- [ ] User training

### Backup Strategy

#### Firestore Backup
```bash
# Automated daily backups
gcloud firestore export gs://unimark-backups/firestore/$(date +%Y%m%d)
```

#### Cloud Functions Backup
```bash
# Backup function source code
git tag v$(date +%Y%m%d)
git push origin v$(date +%Y%m%d)
```

### Disaster Recovery

#### Rollback Plan
1. **Immediate**: Disable new user registrations
2. **Short-term**: Rollback to previous version
3. **Long-term**: Restore from backup

#### Recovery Steps
1. Identify the issue
2. Assess impact
3. Implement fix or rollback
4. Verify resolution
5. Update monitoring

## 📊 Monitoring & Alerts

### Key Metrics
- **Authentication Success Rate**: > 99%
- **Attendance Submission Success Rate**: > 99%
- **Response Time**: < 3 seconds
- **Error Rate**: < 0.1%
- **Uptime**: > 99.9%

### Alerts
- High error rate (> 1%)
- Authentication failures
- Database connection issues
- Function timeouts
- Security violations

### Dashboards
- Real-time user activity
- System performance
- Security events
- Business metrics

## 🆘 Troubleshooting

### Common Issues

#### Authentication Issues
- Check OAuth configuration
- Verify domain restrictions
- Check token expiration
- Review audit logs

#### Performance Issues
- Check function execution time
- Monitor database queries
- Review resource usage
- Optimize code

#### Security Issues
- Review security rules
- Check App Check status
- Verify Play Integrity
- Monitor audit logs

### Support Contacts
- **Technical Lead**: [Contact Info]
- **Security Lead**: [Contact Info]
- **Firebase Support**: [Contact Info]
- **Emergency Contact**: [Contact Info]

---

**Remember**: Always test in staging environment before deploying to production!
