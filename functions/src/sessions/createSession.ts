import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { CallableRequest } from 'firebase-functions/v2/https';
import { CreateSessionRequest, ApiResponse, ERROR_CODES, SYSTEM_CONSTANTS } from '../types';
import { auditLog } from '../audit/auditLog';

export const createSession = async (
  request: CallableRequest<CreateSessionRequest>
): Promise<ApiResponse> => {
  const db = admin.firestore();

  try {
    // Verify authentication
    if (!request.auth) {
      throw new Error('Authentication required');
    }

    const userId = request.auth.uid;
    const { branchId, classId, batchIds, subject, ttlSeconds, gpsRadiusM, facultyLocation } = request.data;

    // Get user data and verify faculty role
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const userData = userDoc.data()!;
    if (userData.role !== 'faculty') {
      throw new Error('Only faculty can create sessions');
    }

    // Validate input
    if (!branchId || !classId || !batchIds || !subject || !facultyLocation) {
      throw new Error('Missing required fields');
    }

    if (!Array.isArray(batchIds) || batchIds.length === 0) {
      throw new Error('At least one batch must be selected');
    }

    // Generate session code (3-digit)
    const code = Math.floor(Math.random() * 1000);

    // Generate nonce for security
    const nonce = crypto.randomBytes(16).toString('base64');

    // Set session timing
    const now = admin.firestore.Timestamp.now();
    const sessionTtl = ttlSeconds || SYSTEM_CONSTANTS.DEFAULT_SESSION_TTL;
    const expiresAt = new admin.firestore.Timestamp(
      now.seconds + sessionTtl,
      now.nanoseconds
    );

    // Set edit window (48 hours from now)
    const editableUntil = new admin.firestore.Timestamp(
      now.seconds + SYSTEM_CONSTANTS.ATTENDANCE_EDIT_WINDOW / 1000,
      now.nanoseconds
    );

    // Create session document
    const sessionData = {
      facultyId: userId,
      branchId,
      classId,
      batchIds,
      subject,
      code,
      nonce,
      startAt: now,
      expiresAt,
      ttlSeconds: sessionTtl,
      status: 'open',
      editableUntil,
      facultyLocation: {
        lat: facultyLocation.lat,
        lng: facultyLocation.lng,
        accuracyM: facultyLocation.accuracyM,
      },
      gpsRadiusM: gpsRadiusM || SYSTEM_CONSTANTS.DEFAULT_SESSION_RADIUS,
      stats: {
        presentCount: 0,
        totalCount: 0,
      },
    };

    const sessionRef = await db.collection('sessions').add(sessionData);

    // Log session creation
    await auditLog({
      eventType: 'SESSION_CREATED',
      sessionId: sessionRef.id,
      userId,
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        subject,
        branchId,
        classId,
        batchIds,
        code,
        ttlSeconds: sessionTtl,
        gpsRadiusM: gpsRadiusM || SYSTEM_CONSTANTS.DEFAULT_SESSION_RADIUS,
        facultyLocation,
      },
    });

    return {
      success: true,
      data: {
        sessionId: sessionRef.id,
        code: code.toString().padStart(3, '0'),
        expiresAt: expiresAt.toDate().toISOString(),
        ttlSeconds: sessionTtl,
      },
      message: 'Session created successfully',
    };

  } catch (error) {
    functions.logger.error('Create session error:', error);

    await auditLog({
      eventType: 'SESSION_CREATE_FAILED',
      userId: request.auth?.uid,
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        requestData: request.data,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: error instanceof Error ? error.message : 'Session creation failed',
    };
  }
};
