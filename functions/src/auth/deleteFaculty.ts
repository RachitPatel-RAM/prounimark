import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { DeleteFacultyRequest, ApiResponse, ERROR_CODES } from '../types';
import { auditLog } from '../audit/auditLog';

export const deleteFaculty = async (
  request: CallableRequest<DeleteFacultyRequest>
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

    // Check if faculty has any active sessions
    const activeSessions = await admin.firestore()
      .collection('sessions')
      .where('facultyId', '==', facultyId)
      .where('isActive', '==', true)
      .limit(1)
      .get();

    if (!activeSessions.empty) {
      return {
        success: false,
        error: ERROR_CODES.NOT_AUTHORIZED,
        message: 'Cannot delete faculty with active sessions. Please close all sessions first.',
      };
    }

    // Delete Firebase Auth user
    await admin.auth().deleteUser(facultyId);

    // Delete Firestore document
    await admin.firestore().collection('users').doc(facultyId).delete();

    // Log the action
    await auditLog({
      eventType: 'FACULTY_DELETED',
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
      },
      message: 'Faculty user deleted successfully',
    };

  } catch (error) {
    functions.logger.error('Delete faculty error:', error);
    
    await auditLog({
      eventType: 'FACULTY_DELETE_ERROR',
      userId: request.auth?.uid,
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        facultyId: request.data.facultyId,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Failed to delete faculty user',
    };
  }
};
