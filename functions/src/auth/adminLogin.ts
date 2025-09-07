import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { AdminLoginRequest, ApiResponse, ERROR_CODES, SYSTEM_CONSTANTS } from '../types';
import { auditLog } from '../audit/auditLog';

export const adminLogin = async (
  request: CallableRequest<AdminLoginRequest>
): Promise<ApiResponse> => {
  try {
    const { adminId, password } = request.data;

    // Validate input
    if (!adminId || !password) {
      throw new Error('Admin ID and password are required');
    }

    // Verify admin credentials
    if (adminId !== SYSTEM_CONSTANTS.ADMIN_ID || password !== SYSTEM_CONSTANTS.ADMIN_PASSWORD) {
      await auditLog({
        eventType: 'ADMIN_LOGIN_FAILED',
        ip: request.rawRequest.ip,
        userAgent: request.rawRequest.get('User-Agent'),
        details: {
          adminId,
          reason: 'Invalid credentials',
        },
      });

      return {
        success: false,
        error: ERROR_CODES.INVALID_CREDENTIALS,
        message: 'Invalid admin credentials',
      };
    }

    // Create custom token for admin
    const customToken = await admin.auth().createCustomToken('admin', {
      role: 'admin',
      isAdmin: true,
    });

    await auditLog({
      eventType: 'ADMIN_LOGIN_SUCCESS',
      userId: 'admin',
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        adminId,
      },
    });

    return {
      success: true,
      data: {
        customToken,
        user: {
          id: 'admin',
          name: 'System Administrator',
          email: 'admin@darshan.ac.in',
          role: 'admin',
        },
      },
      message: 'Admin login successful',
    };

  } catch (error) {
    functions.logger.error('Admin login error:', error);
    
    await auditLog({
      eventType: 'ADMIN_LOGIN_ERROR',
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: 'Admin login failed',
    };
  }
};
