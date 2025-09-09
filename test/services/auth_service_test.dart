import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_functions/firebase_functions.dart'; // Discontinued
import 'package:unimark/services/auth_service.dart';
import 'package:unimark/models/user_model.dart';

import 'auth_service_test.mocks.dart';

// Using generated mocks for DocumentSnapshot

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  FirebaseFirestore,
  User,
  UserCredential,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  DocumentSnapshot,
])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockFirebaseFirestore mockFirestore;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    });

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockFirestore = MockFirebaseFirestore();
      
      authService = AuthService();
    });

    group('signInWithGoogle', () {
      test('should successfully sign in with valid @darshan.ac.in email', () async {
        // Arrange
        final mockGoogleUser = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();
        when(mockGoogleUser.email).thenReturn('test@darshan.ac.in');
        when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
        when(mockGoogleAuth.accessToken).thenReturn('access-token');
        when(mockGoogleAuth.idToken).thenReturn('id-token');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
        when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn({
          'name': 'Test User',
          'email': 'test@darshan.ac.in',
          'role': 'student',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'isActive': true,
        });
        when(mockFirestore.collection('users').doc('test-uid').get())
            .thenAnswer((_) async => mockDocSnapshot);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isNotNull);
        expect(result.isSuccess, isTrue);
        expect(result.user?.email, equals('test@darshan.ac.in'));
      });

      test('should fail with non-darshan.ac.in email', () async {
        // Arrange
        final mockGoogleUser = MockGoogleSignInAccount();
        when(mockGoogleUser.email).thenReturn('test@gmail.com');
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);

        // Act
        final result = await authService.signInWithGoogle();
        
        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('Access denied'));
      });

      test('should return needsRegistration for new user', () async {
        // Arrange
        final mockGoogleUser = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();
        when(mockGoogleUser.email).thenReturn('newuser@darshan.ac.in');
        when(mockGoogleUser.authentication).thenAnswer((_) async => mockGoogleAuth);
        when(mockGoogleAuth.accessToken).thenReturn('access-token');
        when(mockGoogleAuth.idToken).thenReturn('id-token');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('new-uid');

        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
        when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        when(mockDocSnapshot.exists).thenReturn(false);
        when(mockDocSnapshot.data()).thenReturn(null);
        when(mockFirestore.collection('users').doc('new-uid').get())
            .thenAnswer((_) async => mockDocSnapshot);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isNotNull);
        expect(result.needsRegistration, isTrue);
        expect(result.firebaseUser?.uid, equals('new-uid'));
      });
    });

    group('adminLogin', () {
      test('should successfully login with valid admin credentials', () async {
        // Act
        final result = await authService.adminLogin('ADMIN404', 'ADMIN9090@@@@');

        // Assert
        expect(result, isNotNull);
        expect(result.isSuccess, isTrue);
        expect(result.user?.role, equals(UserRole.admin));
        expect(result.user?.email, equals('admin@darshan.ac.in'));
      });

      test('should fail with invalid admin credentials', () async {
        // Act
        final result = await authService.adminLogin('WRONG_ID', 'WRONG_PASSWORD');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('Invalid admin credentials'));
      });
    });

    group('completeStudentRegistration', () {
      test('should successfully complete student registration', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.displayName).thenReturn('Test User');
        when(mockUser.email).thenReturn('test@darshan.ac.in');
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await authService.completeStudentRegistration(
          enrollmentNo: 'CS2024001',
          branchId: 'CS',
          classId: 'CS-A',
          batchId: '2024',
          pin: '1234',
        );

        // Assert
        expect(result, isNotNull);
        expect(result.isSuccess, isTrue);
        expect(result.user?.role, equals(UserRole.student));
        expect(result.user?.enrollmentNo, equals('CS2024001'));
      });

      test('should fail when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await authService.completeStudentRegistration(
          enrollmentNo: 'CS2024001',
          branchId: 'CS',
          classId: 'CS-A',
          batchId: '2024',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, contains('No authenticated user found'));
      });
    });
  });
}
