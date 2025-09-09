import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { UpdateFacultyRequest, ApiResponse, ERROR_CODES } from '../types';
import { auditLog } from '../audit/auditLog';

export const updateFaculty = async (
  request: CallableRequest<UpdateFacultyRequest>
): Promise<ApiResponse> => {
  try {
    const { facultyId, name } = request.data;
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

    // Prepare update data
    const updateData: any = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (name && name.trim() !== '') {
      updateData.name = name.trim();
    }

    // Update Firestore document
    await admin.firestore().collection('users').doc(facultyId).update(updateData);

    // Update Firebase Auth display name if name was changed
    if (name && name.trim() !== '') {
      await admin.auth().updateUser(facultyId, {
        displayName: name.trim(),
      });
    }

    // Log the action
    await auditLog({
      eventType: 'FACULTY_UPDATED',
      userId: adminUid,
      details: {
        facultyId: facultyId,
        facultyEmail: facultyData.email,
        changes: {
          name: name ? { from: facultyData.name, to: name.trim() } : null,
        },
      },
    });

    return {
      success: true,
      data: {
        facultyId: facultyId,
        updatedFields: Object.keys(updateData).filter(key => key !== 'updatedAt'),
      },
      message: 'Faculty user updated successfully',
    };

  } catch (error) {
    functions.logger.error('Update faculty error:', error);
    
    await auditLog({
      eventType: 'FACULTY_UPDATE_ERROR',
      userId: request.auth?.uid,
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        facultyId: request.data.facultyId,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Failed to update faculty user',
    };
  }
};
