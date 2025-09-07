import { adminLogin } from '../../auth/adminLogin';
import { CallableRequest } from 'firebase-functions/v2/https';
import { SYSTEM_CONSTANTS } from '../../types';

// Mock Firebase Admin
jest.mock('firebase-admin', () => ({
  auth: () => ({
    createCustomToken: jest.fn().mockResolvedValue('mock-custom-token'),
  }),
}));

// Mock audit log
jest.mock('../../audit/auditLog', () => ({
  auditLog: jest.fn().mockResolvedValue(undefined),
}));

describe('adminLogin', () => {
  const mockRequest = (data: any): CallableRequest<any> => ({
    data,
    auth: null,
    rawRequest: {
      ip: '127.0.0.1',
      get: jest.fn().mockReturnValue('test-user-agent'),
    } as any,
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should successfully authenticate with valid admin credentials', async () => {
    const request = mockRequest({
      adminId: SYSTEM_CONSTANTS.ADMIN_ID,
      password: SYSTEM_CONSTANTS.ADMIN_PASSWORD,
    });

    const result = await adminLogin(request);

    expect(result.success).toBe(true);
    expect(result.data).toHaveProperty('customToken', 'mock-custom-token');
    expect(result.data.user).toEqual({
      id: 'admin',
      name: 'System Administrator',
      email: 'admin@darshan.ac.in',
      role: 'admin',
    });
  });

  it('should fail with invalid admin credentials', async () => {
    const request = mockRequest({
      adminId: 'INVALID_ID',
      password: 'INVALID_PASSWORD',
    });

    const result = await adminLogin(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_INVALID_CREDENTIALS');
    expect(result.message).toBe('Invalid admin credentials');
  });

  it('should fail with missing credentials', async () => {
    const request = mockRequest({});

    const result = await adminLogin(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_NOT_AUTHORIZED');
    expect(result.message).toBe('Admin login failed');
  });

  it('should fail with partial credentials', async () => {
    const request = mockRequest({
      adminId: SYSTEM_CONSTANTS.ADMIN_ID,
      // Missing password
    });

    const result = await adminLogin(request);

    expect(result.success).toBe(false);
    expect(result.error).toBe('ERR_NOT_AUTHORIZED');
    expect(result.message).toBe('Admin login failed');
  });
});
