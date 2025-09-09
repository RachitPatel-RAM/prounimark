import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { CreateFacultyRequest, ApiResponse, ERROR_CODES, SYSTEM_CONSTANTS } from '../types';
import { auditLog } from '../audit/auditLog';

export const createFaculty = async (
  request: CallableRequest<CreateFacultyRequest>
): Promise<ApiResponse> => {
  try {
    const { email, name, branchId, temporaryPassword } = request.data;
    const adminUid = request.auth?.uid;

    // Verify admin role
    if (!adminUid || !request.auth?.token?.role || request.auth.token.role !== 'admin') {
      return {
        success: false,
        error: ERROR_CODES.NOT_AUTHORIZED,
        message: 'Admin access required',
      };
    }

    // Validate input
    if (!email || !name) {
      return {
        success: false,
        error: ERROR_CODES.INVALID_CREDENTIALS,
        message: 'Email and name are required',
      };
    }

    // Validate email format and domain
    if (!email.endsWith(SYSTEM_CONSTANTS.UNIVERSITY_DOMAIN)) {
      return {
        success: false,
        error: ERROR_CODES.DOMAIN_NOT_ALLOWED,
        message: 'Faculty email must be from @darshan.ac.in domain',
      };
    }

    // Check if user already exists
    const existingUser = await admin.auth().getUserByEmail(email).catch(() => null);
    if (existingUser) {
      return {
        success: false,
        error: ERROR_CODES.DUPLICATE,
        message: 'Faculty user with this email already exists',
      };
    }

    // Generate temporary password if not provided
    const password = temporaryPassword || generateTemporaryPassword();

    // Create Firebase Auth user
    const userRecord = await admin.auth().createUser({
      email: email,
      displayName: name,
      password: password,
      emailVerified: false,
    });

    // Create user document in Firestore
    const userData = {
      name: name,
      email: email,
      role: 'faculty',
      branch: branchId || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    };

    await admin.firestore().collection('users').doc(userRecord.uid).set(userData);

    // Set custom claims for faculty role
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: 'faculty',
      isFaculty: true,
    });

    // Log the action
    await auditLog({
      eventType: 'FACULTY_CREATED',
      userId: adminUid,
      details: {
        facultyId: userRecord.uid,
        facultyEmail: email,
        facultyName: name,
        branchId: branchId || null,
      },
    });

    return {
      success: true,
      data: {
        facultyId: userRecord.uid,
        email: email,
        name: name,
        temporaryPassword: password,
      },
      message: 'Faculty user created successfully',
    };

  } catch (error) {
    functions.logger.error('Create faculty error:', error);
    
    await auditLog({
      eventType: 'FACULTY_CREATE_ERROR',
      userId: request.auth?.uid,
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        email: request.data.email,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Failed to create faculty user',
    };
  }
};

function generateTemporaryPassword(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let password = '';
  for (let i = 0; i < 12; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}
