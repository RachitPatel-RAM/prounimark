import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { User } from '../types';

const db = admin.firestore();

interface CreateFacultyUserRequest {
  email: string;
  name: string;
  branchId?: string;
  temporaryPassword?: string;
}

interface CreateFacultyUserResponse {
  success: boolean;
  userId?: string;
  temporaryPassword?: string;
  error?: string;
}

export const createFacultyUser = functions.https.onCall(
  async (data: CreateFacultyUserRequest, context): Promise<CreateFacultyUserResponse> => {
    try {
      // Verify admin authentication
      if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
      }

      // Check if user is admin
      const adminUser = await db.collection('users').doc(context.auth.uid).get();
      if (!adminUser.exists || adminUser.data()?.role !== 'admin') {
        throw new functions.https.HttpsError('permission-denied', 'Only admins can create faculty users');
      }

      // Validate input
      if (!data.email || !data.name) {
        throw new functions.https.HttpsError('invalid-argument', 'Email and name are required');
      }

      // Validate email domain
      if (!data.email.endsWith('@darshan.ac.in')) {
        throw new functions.https.HttpsError('invalid-argument', 'Email must be from @darshan.ac.in domain');
      }

      // Check if user already exists
      const existingUser = await admin.auth().getUserByEmail(data.email);
      if (existingUser) {
        throw new functions.https.HttpsError('already-exists', 'User with this email already exists');
      }

      // Generate temporary password if not provided
      const temporaryPassword = data.temporaryPassword || generateTemporaryPassword();

      // Create Firebase Auth user
      const userRecord = await admin.auth().createUser({
        email: data.email,
        password: temporaryPassword,
        displayName: data.name,
        emailVerified: false,
      });

      // Create user document in Firestore
      const userData: User = {
        id: userRecord.uid,
        name: data.name,
        email: data.email,
        role: 'faculty',
        branch: data.branchId || null,
        tempPassword: true,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now(),
        isActive: true,
      };

      await db.collection('users').doc(userRecord.uid).set(userData);

      // Log the action
      await db.collection('auditLogs').add({
        eventType: 'FACULTY_CREATED',
        adminUid: context.auth.uid,
        facultyUid: userRecord.uid,
        facultyEmail: data.email,
        facultyName: data.name,
        timestamp: admin.firestore.Timestamp.now(),
      });

      return {
        success: true,
        userId: userRecord.uid,
        temporaryPassword: temporaryPassword,
      };
    } catch (error) {
      console.error('Error creating faculty user:', error);
      
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      throw new functions.https.HttpsError('internal', 'Failed to create faculty user');
    }
  }
);

function generateTemporaryPassword(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let password = '';
  
  // Ensure at least one character from each required category
  password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 26)]; // Uppercase
  password += 'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)]; // Lowercase
  password += '0123456789'[Math.floor(Math.random() * 10)]; // Number
  password += '!@#$%^&*'[Math.floor(Math.random() * 8)]; // Special character
  
  // Fill the rest randomly
  for (let i = 4; i < 12; i++) {
    password += chars[Math.floor(Math.random() * chars.length)];
  }
  
  // Shuffle the password
  return password.split('').sort(() => Math.random() - 0.5).join('');
}
