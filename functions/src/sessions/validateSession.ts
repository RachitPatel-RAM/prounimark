import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface ValidateSessionRequest {
  sessionCode: string;
  studentLocation: {
    latitude: number;
    longitude: number;
    accuracy: number;
  };
}

interface ValidateSessionResponse {
  success: boolean;
  sessionId?: string;
  sessionData?: any;
  error?: string;
}

export const validateSession = functions.https.onCall(
  async (data: ValidateSessionRequest, context): Promise<ValidateSessionResponse> => {
    try {
      // Verify student authentication
      if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
      }

      // Check if user is a student
      const userDoc = await db.collection('users').doc(context.auth.uid).get();
      if (!userDoc.exists || userDoc.data()?.role !== 'student') {
        throw new functions.https.HttpsError('permission-denied', 'Only students can validate sessions');
      }

      // Validate input
      if (!data.sessionCode || !data.studentLocation) {
        throw new functions.https.HttpsError('invalid-argument', 'Session code and location are required');
      }

      // Find active session with the given code
      const sessionsQuery = await db
        .collection('sessions')
        .where('sessionCode', '==', data.sessionCode)
        .where('isActive', '==', true)
        .limit(1)
        .get();

      if (sessionsQuery.empty) {
        throw new functions.https.HttpsError('not-found', 'Invalid or expired session code');
      }

      const sessionDoc = sessionsQuery.docs[0];
      const sessionData = sessionDoc.data();

      // Check if session is still within time limit (5 minutes)
      const sessionStartTime = sessionData.startTime.toDate();
      const now = new Date();
      const timeDiff = now.getTime() - sessionStartTime.getTime();
      const minutesDiff = timeDiff / (1000 * 60);

      if (minutesDiff > 5) {
        throw new functions.https.HttpsError('deadline-exceeded', 'Session code has expired');
      }

      // Check if student is already marked present
      if (sessionData.studentsPresent && sessionData.studentsPresent.includes(context.auth.uid)) {
        throw new functions.https.HttpsError('already-exists', 'Attendance already marked for this session');
      }

      // Validate location (within 500m radius)
      const distance = calculateDistance(
        sessionData.gpsLocation.latitude,
        sessionData.gpsLocation.longitude,
        data.studentLocation.latitude,
        data.studentLocation.longitude
      );

      if (distance > sessionData.radius) {
        throw new functions.https.HttpsError('out-of-range', `You are ${distance.toFixed(0)}m away from the session location. Please move closer.`);
      }

      // Check if student is eligible for this session
      const userData = userDoc.data();
      if (sessionData.batchName && userData?.batchId !== sessionData.batchName) {
        throw new functions.https.HttpsError('permission-denied', 'You are not eligible for this session');
      }

      return {
        success: true,
        sessionId: sessionDoc.id,
        sessionData: {
          course: sessionData.course,
          className: sessionData.className,
          batchName: sessionData.batchName,
          distance: distance,
        },
      };
    } catch (error) {
      console.error('Error validating session:', error);
      
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      throw new functions.https.HttpsError('internal', 'Failed to validate session');
    }
  }
);

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // Earth's radius in meters
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}
