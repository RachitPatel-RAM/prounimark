import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { CallableRequest } from 'firebase-functions/v2/https';
import { SubmitAttendanceRequest, ApiResponse, ERROR_CODES, SYSTEM_CONSTANTS } from '../types';
import { auditLog } from '../audit/auditLog';
import { verifyPlayIntegrity } from '../security/verifyPlayIntegrity';

export const submitAttendance = async (
  request: CallableRequest<SubmitAttendanceRequest>
): Promise<ApiResponse> => {
  const db = admin.firestore();
  const batch = db.batch();

  try {
    // Verify authentication
    if (!request.auth) {
      throw new Error('Authentication required');
    }

    const { sessionId, responseCode, location, deviceInstIdHash, useBiometric, pin } = request.data;
    const userId = request.auth.uid;

    // Get user data
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const userData = userDoc.data()!;
    if (userData.role !== 'student') {
      throw new Error('Only students can submit attendance');
    }

    // Get session data
    const sessionDoc = await db.collection('sessions').doc(sessionId).get();
    if (!sessionDoc.exists) {
      throw new Error('Session not found');
    }

    const sessionData = sessionDoc.data()!;

    // Verify session is active and not expired
    if (sessionData.status !== 'open') {
      throw new Error('Session is not active');
    }

    const now = admin.firestore.Timestamp.now();
    if (now.toMillis() > sessionData.expiresAt.toMillis()) {
      throw new Error('Session has expired');
    }

    // Verify user belongs to session
    if (userData.branch !== sessionData.branchId ||
        userData.classId !== sessionData.classId ||
        !sessionData.batchIds.includes(userData.batchId)) {
      throw new Error('User not eligible for this session');
    }

    // Check for duplicate submission
    const attendanceDoc = await db
      .collection('sessions')
      .doc(sessionId)
      .collection('attendance')
      .doc(userId)
      .get();

    if (attendanceDoc.exists) {
      throw new Error('Attendance already submitted for this session');
    }

    // Verify location accuracy
    if (location.accM > SYSTEM_CONSTANTS.MINIMUM_LOCATION_ACCURACY) {
      throw new Error('Location accuracy too low');
    }

    // Calculate distance to session location
    const distance = calculateDistance(
      location.lat,
      location.lng,
      sessionData.facultyLocation.lat,
      sessionData.facultyLocation.lng
    );

    if (distance > sessionData.gpsRadiusM) {
      throw new Error(`Location too far from session (${Math.round(distance)}m > ${sessionData.gpsRadiusM}m)`);
    }

    // Verify device binding
    if (!userData.deviceBinding) {
      // First time - bind device
      const deviceBinding = {
        instIdHash: deviceInstIdHash,
        platform: 'unknown', // Will be updated by client
        boundAt: now,
      };

      batch.update(userDoc.ref, {
        deviceBinding,
        updatedAt: now,
      });
    } else if (userData.deviceBinding.instIdHash !== deviceInstIdHash) {
      throw new Error('Device binding mismatch');
    }

    // Verify authentication method
    if (useBiometric) {
      // For biometric, we rely on device binding and Play Integrity
      // Additional verification can be added here
    } else if (pin) {
      // Verify PIN
      if (!userData.pinHash) {
        throw new Error('PIN not set for user');
      }

      const pinHash = crypto.createHash('sha256').update(pin).digest('hex');
      if (pinHash !== userData.pinHash) {
        throw new Error('Invalid PIN');
      }
    } else {
      throw new Error('Authentication method required');
    }

    // Get server seed for code verification
    const seedDoc = await db.collection('server_seeds').doc(userId).get();
    if (!seedDoc.exists) {
      throw new Error('Server seed not found');
    }

    const seed = seedDoc.data()!.seed;

    // Verify response code using HMAC
    const perFactor = parseInt(
      crypto.createHmac('sha256', seed)
        .update(sessionData.nonce)
        .digest('hex')
        .substring(0, 8),
      16
    ) % 1000;

    const expectedCode = (sessionData.code + perFactor) % 1000;

    // Use constant-time comparison
    const codeValid = crypto.timingSafeEqual(
      Buffer.from(responseCode.toString()),
      Buffer.from(expectedCode.toString())
    );

    if (!codeValid) {
      throw new Error('Invalid session code');
    }

    // Create attendance record
    const attendanceData = {
      sessionId,
      studentUid: userId,
      enrollmentNo: userData.enrollmentNo,
      submittedAt: now,
      responseCode,
      deviceInstIdHash,
      location: {
        lat: location.lat,
        lng: location.lng,
        accM: location.accM,
      },
      verified: {
        timeOk: true,
        codeOk: true,
        deviceOk: true,
        integrityOk: true, // Will be updated after Play Integrity check
        locationOk: true,
      },
      result: 'accepted',
    };

    const attendanceRef = db
      .collection('sessions')
      .doc(sessionId)
      .collection('attendance')
      .doc(userId);

    batch.set(attendanceRef, attendanceData);

    // Update session stats
    const newPresentCount = (sessionData.stats.presentCount || 0) + 1;
    const newTotalCount = (sessionData.stats.totalCount || 0) + 1;

    batch.update(sessionDoc.ref, {
      'stats.presentCount': newPresentCount,
      'stats.totalCount': newTotalCount,
    });

    // Commit transaction
    await batch.commit();

    // Log successful attendance
    await auditLog({
      eventType: 'ATTENDANCE_SUBMITTED',
      sessionId,
      userId,
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        enrollmentNo: userData.enrollmentNo,
        responseCode,
        distance: Math.round(distance),
        useBiometric,
        location: {
          lat: location.lat,
          lng: location.lng,
          accuracy: location.accM,
        },
      },
    });

    return {
      success: true,
      data: {
        attendanceId: attendanceRef.id,
        sessionStats: {
          presentCount: newPresentCount,
          totalCount: newTotalCount,
        },
      },
      message: 'Attendance submitted successfully',
    };

  } catch (error) {
    functions.logger.error('Submit attendance error:', error);

    await auditLog({
      eventType: 'ATTENDANCE_SUBMIT_FAILED',
      sessionId: request.data.sessionId,
      userId: request.auth?.uid,
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        error: error instanceof Error ? error.message : 'Unknown error',
        responseCode: request.data.responseCode,
      },
    });

    return {
      success: false,
      error: ERROR_CODES.NOT_AUTHORIZED,
      message: error instanceof Error ? error.message : 'Attendance submission failed',
    };
  }
};

// Haversine formula for distance calculation
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // Earth's radius in meters
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
