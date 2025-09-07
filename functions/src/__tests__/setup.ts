import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions-test';

// Initialize Firebase Admin for testing
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'test-project',
  });
}

// Initialize Firebase Functions test environment
const testEnv = functions({
  projectId: 'test-project',
});

export { testEnv };
export default testEnv;
