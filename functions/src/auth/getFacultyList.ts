import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { GetFacultyListRequest, ApiResponse, ERROR_CODES } from '../types';

export const getFacultyList = async (
  request: CallableRequest<GetFacultyListRequest>
): Promise<ApiResponse> => {
  try {
    const { searchQuery, limit = 50, offset = 0 } = request.data;
    const adminUid = request.auth?.uid;

    // Verify admin role
    if (!adminUid || !request.auth?.token?.role || request.auth.token.role !== 'admin') {
      return {
        success: false,
        error: ERROR_CODES.NOT_AUTHORIZED,
        message: 'Admin access required',
      };
    }

    let query = admin.firestore()
      .collection('users')
      .where('role', '==', 'faculty')
      .orderBy('name')
      .limit(limit)
      .offset(offset);

    // Apply search filter if provided
    if (searchQuery && searchQuery.trim() !== '') {
      const searchTerm = searchQuery.trim().toLowerCase();
      // Note: Firestore doesn't support case-insensitive search natively
      // This is a simplified implementation - in production, you might want to use Algolia or similar
      query = query.where('name', '>=', searchTerm)
                  .where('name', '<=', searchTerm + '\uf8ff');
    }

    const snapshot = await query.get();
    
    const facultyList = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        name: data.name,
        email: data.email,
        branch: data.branch || null,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        isActive: data.isActive,
      };
    });

    // Get total count for pagination
    const totalCount = await admin.firestore()
      .collection('users')
      .where('role', '==', 'faculty')
      .get()
      .then(snapshot => snapshot.size);

    return {
      success: true,
      data: {
        facultyList: facultyList,
        totalCount: totalCount,
        hasMore: (offset + limit) < totalCount,
      },
      message: 'Faculty list retrieved successfully',
    };

  } catch (error) {
    functions.logger.error('Get faculty list error:', error);
    
    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Failed to retrieve faculty list',
    };
  }
};
