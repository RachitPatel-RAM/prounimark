import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { AuditLog } from '../types';

interface AuditLogRequest {
  eventType: string;
  sessionId?: string;
  userId?: string;
  ip?: string;
  userAgent?: string;
  details: Record<string, any>;
}

export const auditLog = async (request: AuditLogRequest): Promise<void> => {
  const db = admin.firestore();

  try {
    const now = admin.firestore.Timestamp.now();
    
    const auditData: Omit<AuditLog, 'id'> = {
      eventType: request.eventType,
      sessionId: request.sessionId,
      userId: request.userId,
      ip: request.ip,
      userAgent: request.userAgent,
      details: request.details,
      createdAt: now,
    };

    // Add to audit logs collection
    await db.collection('auditLogs').add(auditData);

    // Log to Cloud Logging for monitoring
    functions.logger.info('Audit log created', {
      eventType: request.eventType,
      userId: request.userId,
      sessionId: request.sessionId,
      details: request.details,
    });

  } catch (error) {
    functions.logger.error('Failed to create audit log:', error);
    // Don't throw error to avoid breaking the main operation
  }
};
