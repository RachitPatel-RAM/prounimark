import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { CallableRequest } from 'firebase-functions/v2/https';
import { CompleteStudentRegistrationRequest, ApiResponse, ERROR_CODES, SYSTEM_CONSTANTS } from '../types';
import { auditLog } from '../audit/auditLog';

export const completeStudentRegistration = async (
  request: CallableRequest<CompleteStudentRegistrationRequest>
): Promise<ApiResponse> => {
  const db = admin.firestore();

  try {
    // Verify authentication
    if (!request.auth) {
      throw new Error('Authentication required');
    }

    const userId = request.auth.uid;
    const { enrollmentNo, branchId, classId, batchId, phone, pin, deviceUuid, instIdHash } = request.data;

    // Validate input
    if (!enrollmentNo || !branchId || !classId || !batchId || !deviceUuid || !instIdHash) {
      throw new Error('Missing required fields');
    }

    // Check if user already exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists) {
      throw new Error('User already registered');
    }

    // Verify enrollment number is unique
    const enrollmentQuery = await db
      .collection('users')
      .where('enrollmentNo', '==', enrollmentNo.toUpperCase())
      .get();

    if (!enrollmentQuery.empty) {
      throw new Error('Enrollment number already exists');
    }

    // Verify branch, class, and batch exist
    const [branchDoc, classDoc, batchDoc] = await Promise.all([
      db.collection('branches').doc(branchId).get(),
      db.collection('classes').doc(classId).get(),
      db.collection('batches').doc(batchId).get(),
    ]);

    if (!branchDoc.exists || !classDoc.exists || !batchDoc.exists) {
      throw new Error('Invalid branch, class, or batch');
    }

    // Verify class belongs to branch
    if (classDoc.data()!.branchId !== branchId) {
      throw new Error('Class does not belong to specified branch');
    }

    // Verify batch belongs to class
    if (batchDoc.data()!.classId !== classId) {
      throw new Error('Batch does not belong to specified class');
    }

    // Generate PIN hash if provided
    let pinHash: string | undefined;
    if (pin) {
      if (!/^\d{4}$/.test(pin)) {
        throw new Error('PIN must be 4 digits');
      }
      pinHash = crypto.createHash('sha256').update(pin).digest('hex');
    }

    // Generate server seed for this user
    const serverSeed = crypto.randomBytes(32).toString('hex');

    // Create user document
    const now = admin.firestore.Timestamp.now();
    const userData = {
      name: request.auth.token.name || 'Student',
      email: request.auth.token.email,
      role: 'student',
      enrollmentNo: enrollmentNo.toUpperCase(),
      branch: branchId,
      classId,
      batchId,
      deviceBinding: {
        instIdHash,
        platform: 'unknown', // Will be updated by client
        boundAt: now,
      },
      pinHash,
      phone,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    };

    // Create server seed document
    const seedData = {
      seed: serverSeed,
      createdAt: now,
    };

    // Use batch write for atomicity
    const batch = db.batch();
    
    batch.set(db.collection('users').doc(userId), userData);
    batch.set(db.collection('server_seeds').doc(userId), seedData);

    await batch.commit();

    // Log registration
    await auditLog({
      eventType: 'STUDENT_REGISTERED',
      userId,
      ip: request.rawRequest.ip,
      userAgent: request.rawRequest.get('User-Agent'),
      details: {
        enrollmentNo: enrollmentNo.toUpperCase(),
        branchId,
        classId,
        batchId,
        hasPin: !!pin,
        deviceUuid,
        instIdHash,
      },
    });

    return {
      success: true,
      data: {
        user: userData,
      },
      message: 'Student registration completed successfully',
    };

  } catch (error) {
    functions.logger.error('Complete student registration error:', error);

    await auditLog({
      eventType: 'STUDENT_REGISTRATION_FAILED',
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
      message: error instanceof Error ? error.message : 'Registration failed',
    };
  }
};
