import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { ResetFacultyPasswordRequest, ApiResponse, ERROR_CODES } from '../types';
import { auditLog } from '../audit/auditLog';

export const resetFacultyPassword = async (
  request: CallableRequest<ResetFacultyPasswordRequest>
): Promise<ApiResponse> => {
  try {
    const { facultyId } = request.data;
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
    if (!facultyId) {
      return {
        success: false,
        error: ERROR_CODES.INVALID_CREDENTIALS,
        message: 'Faculty ID is required',
      };
    }

    // Check if faculty exists
    const facultyDoc = await admin.firestore().collection('users').doc(facultyId).get();
    if (!facultyDoc.exists) {
      return {
        success: false,
        error: ERROR_CODES.USER_NOT_FOUND,
        message: 'Faculty user not found',
      };
    }

    const facultyData = facultyDoc.data()!;
    if (facultyData.role !== 'faculty') {
      return {
        success: false,
        error: ERROR_CODES.NOT_AUTHORIZED,
        message: 'User is not a faculty member',
      };
    }

    // Generate new temporary password
    const newPassword = generateTemporaryPassword();

    // Update Firebase Auth user password
    await admin.auth().updateUser(facultyId, {
      password: newPassword,
    });

    // Log the action
    await auditLog({
      eventType: 'FACULTY_PASSWORD_RESET',
      userId: adminUid,
      details: {
        facultyId: facultyId,
        facultyEmail: facultyData.email,
        facultyName: facultyData.name,
      },
    });

    return {
      success: true,
      data: {
        facultyId: facultyId,
        newPassword: newPassword,
      },
      message: 'Faculty password reset successfully',
    };

  } catch (error) {
    functions.logger.error('Reset faculty password error:', error);
    
    await auditLog({
      eventType: 'FACULTY_PASSWORD_RESET_ERROR',
      userId: request.auth?.uid,
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        facultyId: request.data.facultyId,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Failed to reset faculty password',
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
