import { CallableRequest } from 'firebase-functions/v2/https';

// User Types
export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'faculty' | 'student';
  enrollmentNo?: string;
  branch?: string;
  classId?: string;
  batchId?: string;
  deviceBinding?: DeviceBinding;
  pinHash?: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  isActive: boolean;
}

export interface DeviceBinding {
  instIdHash: string;
  platform: string;
  boundAt: admin.firestore.Timestamp;
}

// Session Types
export interface Session {
  id: string;
  facultyId: string;
  branchId: string;
  classId: string;
  batchIds: string[];
  subject: string;
  code: number;
  nonce: string;
  startAt: admin.firestore.Timestamp;
  expiresAt: admin.firestore.Timestamp;
  ttlSeconds: number;
  status: 'open' | 'closed' | 'locked';
  editableUntil: admin.firestore.Timestamp;
  facultyLocation: FacultyLocation;
  gpsRadiusM: number;
  stats: SessionStats;
}

export interface FacultyLocation {
  lat: number;
  lng: number;
  accuracyM: number;
}

export interface SessionStats {
  presentCount: number;
  totalCount: number;
}

// Attendance Types
export interface Attendance {
  id: string;
  sessionId: string;
  studentUid: string;
  enrollmentNo: string;
  submittedAt: admin.firestore.Timestamp;
  responseCode: number;
  deviceInstIdHash: string;
  location: StudentLocation;
  verified: VerificationFlags;
  result: 'accepted' | 'rejected';
  reason?: string;
  editedBy?: string;
  editedAt?: admin.firestore.Timestamp;
}

export interface StudentLocation {
  lat: number;
  lng: number;
  accM: number;
}

export interface VerificationFlags {
  timeOk: boolean;
  codeOk: boolean;
  deviceOk: boolean;
  integrityOk: boolean;
  locationOk: boolean;
}

// Hierarchy Types
export interface Branch {
  id: string;
  name: string;
  createdAt: admin.firestore.Timestamp;
  isActive: boolean;
}

export interface Class {
  id: string;
  branchId: string;
  name: string;
  createdAt: admin.firestore.Timestamp;
  isActive: boolean;
}

export interface Batch {
  id: string;
  classId: string;
  name: string;
  createdAt: admin.firestore.Timestamp;
  isActive: boolean;
}

// Audit Types
export interface AuditLog {
  id: string;
  eventType: string;
  sessionId?: string;
  userId?: string;
  ip?: string;
  userAgent?: string;
  details: Record<string, any>;
  createdAt: admin.firestore.Timestamp;
}

// Request/Response Types
export interface AdminLoginRequest {
  adminId: string;
  password: string;
}

export interface CreateFacultyRequest {
  email: string;
  name: string;
  branchId?: string;
  temporaryPassword?: string;
}

export interface UpdateFacultyRequest {
  facultyId: string;
  name?: string;
}

export interface DeleteFacultyRequest {
  facultyId: string;
}

export interface GetFacultyListRequest {
  searchQuery?: string;
  limit?: number;
  offset?: number;
}

export interface ResetFacultyPasswordRequest {
  facultyId: string;
}

export interface CompleteStudentRegistrationRequest {
  enrollmentNo: string;
  branchId: string;
  classId: string;
  batchId: string;
  phone?: string;
  pin?: string;
  deviceUuid: string;
  instIdHash: string;
}

export interface VerifyPinRequest {
  pin: string;
}

export interface ResetDeviceBindingRequest {
  userId: string;
  reason: string;
}

export interface CreateSessionRequest {
  branchId: string;
  classId: string;
  batchIds: string[];
  subject: string;
  ttlSeconds?: number;
  gpsRadiusM?: number;
  facultyLocation: {
    lat: number;
    lng: number;
    accuracyM: number;
  };
}

export interface SubmitAttendanceRequest {
  sessionId: string;
  responseCode: number;
  location: {
    lat: number;
    lng: number;
    accM: number;
  };
  deviceInstIdHash: string;
  useBiometric: boolean;
  pin?: string;
}

export interface EditAttendanceRequest {
  sessionId: string;
  studentId: string;
  newResult: 'accepted' | 'rejected';
  reason: string;
}

export interface VerifyPlayIntegrityRequest {
  token: string;
}

// Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

// Error Types
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 400
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// Constants
export const ERROR_CODES = {
  NOT_AUTHORIZED: 'ERR_NOT_AUTHORIZED',
  INVALID_CODE: 'ERR_INVALID_CODE',
  OUT_OF_RANGE: 'ERR_OUT_OF_RANGE',
  DUPLICATE: 'ERR_DUPLICATE',
  DEVICE_MISMATCH: 'ERR_DEVICE_MISMATCH',
  PI_FAILED: 'ERR_PI_FAILED',
  PIN_INVALID: 'ERR_PIN_INVALID',
  RATE_LIMITED: 'ERR_RATE_LIMITED',
  SESSION_EXPIRED: 'ERR_SESSION_EXPIRED',
  SESSION_NOT_FOUND: 'ERR_SESSION_NOT_FOUND',
  USER_NOT_FOUND: 'ERR_USER_NOT_FOUND',
  INVALID_CREDENTIALS: 'ERR_INVALID_CREDENTIALS',
  DOMAIN_NOT_ALLOWED: 'ERR_DOMAIN_NOT_ALLOWED',
  DEVICE_BINDING_REQUIRED: 'ERR_DEVICE_BINDING_REQUIRED',
  LOCATION_ACCURACY_TOO_LOW: 'ERR_LOCATION_ACCURACY_TOO_LOW',
  BIOMETRIC_NOT_AVAILABLE: 'ERR_BIOMETRIC_NOT_AVAILABLE',
  SESSION_LOCKED: 'ERR_SESSION_LOCKED',
  EDIT_WINDOW_EXPIRED: 'ERR_EDIT_WINDOW_EXPIRED',
} as const;

export const SYSTEM_CONSTANTS = {
  ADMIN_ID: 'ADMIN',
  ADMIN_PASSWORD: 'ADMIN9090',
  UNIVERSITY_DOMAIN: '@darshan.ac.in',
  DEFAULT_SESSION_RADIUS: 500,
  DEFAULT_SESSION_TTL: 300, // 5 minutes
  ATTENDANCE_EDIT_WINDOW: 48 * 60 * 60 * 1000, // 48 hours in milliseconds
  MAX_LOGIN_ATTEMPTS: 5,
  LOCKOUT_DURATION: 15 * 60 * 1000, // 15 minutes in milliseconds
  MINIMUM_LOCATION_ACCURACY: 50, // meters
} as const;
