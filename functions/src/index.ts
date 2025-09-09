import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { adminLogin } from './auth/adminLogin';
import { createFaculty } from './auth/createFaculty';
import { updateFaculty } from './auth/updateFaculty';
import { deleteFaculty } from './auth/deleteFaculty';
import { getFacultyList } from './auth/getFacultyList';
import { resetFacultyPassword } from './auth/resetFacultyPassword';
import { completeStudentRegistration } from './auth/completeStudentRegistration';
import { verifyPin } from './auth/verifyPin';
import { resetDeviceBinding } from './auth/resetDeviceBinding';
import { createFacultyUser } from './auth/createFacultyUser';
import { createSession } from './sessions/createSession';
import { submitAttendance } from './attendance/submitAttendance';
import { closeSession } from './sessions/closeSession';
import { editAttendance } from './attendance/editAttendance';
import { lockSessions } from './sessions/lockSessions';
import { getActiveSessions } from './sessions/getActiveSessions';
import { validateSession } from './sessions/validateSession';
import { verifyPlayIntegrity } from './security/verifyPlayIntegrity';
import { auditLog } from './audit/auditLog';

// Initialize Firebase Admin
admin.initializeApp();

// Authentication Functions
export const adminLoginFunction = functions.https.onCall(adminLogin);
export const createFacultyFunction = functions.https.onCall(createFaculty);
export const updateFacultyFunction = functions.https.onCall(updateFaculty);
export const deleteFacultyFunction = functions.https.onCall(deleteFaculty);
export const getFacultyListFunction = functions.https.onCall(getFacultyList);
export const resetFacultyPasswordFunction = functions.https.onCall(resetFacultyPassword);
export const completeStudentRegistrationFunction = functions.https.onCall(completeStudentRegistration);
export const verifyPinFunction = functions.https.onCall(verifyPin);
export const resetDeviceBindingFunction = functions.https.onCall(resetDeviceBinding);
export const createFacultyUserFunction = functions.https.onCall(createFacultyUser);

// Session Management Functions
export const createSessionFunction = functions.https.onCall(createSession);
export const closeSessionFunction = functions.https.onCall(closeSession);
export const getActiveSessionsFunction = functions.https.onCall(getActiveSessions);
export const validateSessionFunction = functions.https.onCall(validateSession);

// Attendance Functions
export const submitAttendanceFunction = functions.https.onCall(submitAttendance);
export const editAttendanceFunction = functions.https.onCall(editAttendance);

// Security Functions
export const verifyPlayIntegrityFunction = functions.https.onCall(verifyPlayIntegrity);

// Audit Functions
export const auditLogFunction = functions.https.onCall(auditLog);

// Scheduled Functions
export const lockSessionsScheduled = functions.pubsub
  .schedule('every 1 hours')
  .onRun(lockSessions);

// Firestore Triggers
export const onUserCreate = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    await auditLog({
      eventType: 'USER_CREATED',
      userId: context.params.userId,
      details: {
        role: userData.role,
        email: userData.email,
      },
    });
  });

export const onSessionCreate = functions.firestore
  .document('sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const sessionData = snap.data();
    await auditLog({
      eventType: 'SESSION_CREATED',
      sessionId: context.params.sessionId,
      userId: sessionData.facultyId,
      details: {
        subject: sessionData.subject,
        branchId: sessionData.branchId,
        classId: sessionData.classId,
        batchIds: sessionData.batchIds,
      },
    });
  });

export const onAttendanceSubmit = functions.firestore
  .document('sessions/{sessionId}/attendance/{studentId}')
  .onCreate(async (snap, context) => {
    const attendanceData = snap.data();
    await auditLog({
      eventType: 'ATTENDANCE_SUBMITTED',
      sessionId: context.params.sessionId,
      userId: context.params.studentId,
      details: {
        result: attendanceData.result,
        verified: attendanceData.verified,
        location: attendanceData.location,
      },
    });
  });
