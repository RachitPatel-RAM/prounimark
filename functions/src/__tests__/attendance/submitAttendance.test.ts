import { submitAttendance } from '../../attendance/submitAttendance';
import { CallableRequest } from 'firebase-functions/v2/https';

// Mock Firebase Admin
const mockFirestore = {
  collection: jest.fn(),
  doc: jest.fn(),
  batch: jest.fn(),
};

jest.mock('firebase-admin', () => ({
  firestore: () => mockFirestore,
}));

// Mock audit log
jest.mock('../../audit/auditLog', () => ({
  auditLog: jest.fn().mockResolvedValue(undefined),
}));

describe('submitAttendance', () => {
  const mockRequest = (data: any, auth: any = { uid: 'test-user' }): CallableRequest<any> => ({
    data,
    auth,
    rawRequest: {
      ip: '127.0.0.1',
      get: jest.fn().mockReturnValue('test-user-agent'),
    } as any,
  });

  beforeEach(() => {
    jest.clearAllMocks();
    
    // Setup default mocks
    mockFirestore.collection.mockReturnValue({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({
            role: 'student',
            branch: 'CS',
            classId: 'CS-A',
            batchId: '2024',
            enrollmentNo: 'CS2024001',
            deviceBinding: {
              instIdHash: 'test-hash',
            },
          }),
          ref: { update: jest.fn() },
        }),
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: false,
            }),
            set: jest.fn(),
          }),
        }),
      }),
    });

    mockFirestore.batch.mockReturnValue({
      set: jest.fn(),
      update: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    });
  });

  it('should successfully submit attendance with valid data', async () => {
    // Mock session data
    const sessionData = {
      status: 'open',
      expiresAt: { toMillis: () => Date.now() + 300000 }, // 5 minutes from now
      branchId: 'CS',
      classId: 'CS-A',
      batchIds: ['2024'],
      code: 123,
      nonce: 'test-nonce',
      facultyLocation: { lat: 0, lng: 0 },
      gpsRadiusM: 500,
      stats: { presentCount: 0, totalCount: 0 },
    };

    // Mock user document
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({
            role: 'student',
            branch: 'CS',
            classId: 'CS-A',
            batchId: '2024',
            enrollmentNo: 'CS2024001',
            deviceBinding: {
              instIdHash: 'test-hash',
            },
          }),
          ref: { update: jest.fn() },
        }),
      }),
    });

    // Mock session document
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => sessionData,
          ref: { update: jest.fn() },
        }),
      }),
    });

    // Mock attendance document (not exists)
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: false,
            }),
            set: jest.fn(),
          }),
        }),
      }),
    });

    // Mock server seed
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({ seed: 'test-seed' }),
        }),
      }),
    });

    const request = mockRequest({
      sessionId: 'test-session',
      responseCode: 123,
      location: { lat: 0, lng: 0, accM: 10 },
      deviceInstIdHash: 'test-hash',
      useBiometric: true,
    });

    const result = await submitAttendance(request);

    expect(result.success).toBe(true);
    expect(result.message).toBe('Attendance submitted successfully');
  });

  it('should fail with unauthenticated request', async () => {
    const request = mockRequest({
      sessionId: 'test-session',
      responseCode: 123,
      location: { lat: 0, lng: 0, accM: 10 },
      deviceInstIdHash: 'test-hash',
      useBiometric: true,
    }, null); // No auth

    const result = await submitAttendance(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_NOT_AUTHORIZED');
  });

  it('should fail with non-student user', async () => {
    // Mock user document with faculty role
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({
            role: 'faculty',
            branch: 'CS',
            classId: 'CS-A',
            batchId: '2024',
          }),
        }),
      }),
    });

    const request = mockRequest({
      sessionId: 'test-session',
      responseCode: 123,
      location: { lat: 0, lng: 0, accM: 10 },
      deviceInstIdHash: 'test-hash',
      useBiometric: true,
    });

    const result = await submitAttendance(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_NOT_AUTHORIZED');
  });

  it('should fail with expired session', async () => {
    // Mock user document
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({
            role: 'student',
            branch: 'CS',
            classId: 'CS-A',
            batchId: '2024',
          }),
        }),
      }),
    });

    // Mock expired session
    mockFirestore.collection.mockReturnValueOnce({
      doc: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({
          exists: true,
          data: () => ({
            status: 'open',
            expiresAt: { toMillis: () => Date.now() - 1000 }, // Expired
            branchId: 'CS',
            classId: 'CS-A',
            batchIds: ['2024'],
          }),
        }),
      }),
    });

    const request = mockRequest({
      sessionId: 'test-session',
      responseCode: 123,
      location: { lat: 0, lng: 0, accM: 10 },
      deviceInstIdHash: 'test-hash',
      useBiometric: true,
    });

    const result = await submitAttendance(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_NOT_AUTHORIZED');
  });
});
