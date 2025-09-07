#!/usr/bin/env node

/**
 * UniMark Sample Data Seeding Script
 * This script creates sample data for testing and development
 */

const admin = require('firebase-admin');
const crypto = require('crypto');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID || 'unimark-attendance',
  });
}

const db = admin.firestore();

// Sample data
const sampleData = {
  branches: [
    { id: 'CS', name: 'Computer Science', isActive: true },
    { id: 'IT', name: 'Information Technology', isActive: true },
    { id: 'EC', name: 'Electronics & Communication', isActive: true },
    { id: 'ME', name: 'Mechanical Engineering', isActive: true },
    { id: 'CE', name: 'Civil Engineering', isActive: true },
  ],

  classes: [
    // Computer Science
    { id: 'CS-A', branchId: 'CS', name: 'CS-A', isActive: true },
    { id: 'CS-B', branchId: 'CS', name: 'CS-B', isActive: true },
    { id: 'CS-C', branchId: 'CS', name: 'CS-C', isActive: true },
    
    // Information Technology
    { id: 'IT-A', branchId: 'IT', name: 'IT-A', isActive: true },
    { id: 'IT-B', branchId: 'IT', name: 'IT-B', isActive: true },
    
    // Electronics & Communication
    { id: 'EC-A', branchId: 'EC', name: 'EC-A', isActive: true },
    { id: 'EC-B', branchId: 'EC', name: 'EC-B', isActive: true },
    
    // Mechanical Engineering
    { id: 'ME-A', branchId: 'ME', name: 'ME-A', isActive: true },
    { id: 'ME-B', branchId: 'ME', name: 'ME-B', isActive: true },
    
    // Civil Engineering
    { id: 'CE-A', branchId: 'CE', name: 'CE-A', isActive: true },
  ],

  batches: [
    // CS-A batches
    { id: 'CS-A-2024', classId: 'CS-A', name: '2024', isActive: true },
    { id: 'CS-A-2023', classId: 'CS-A', name: '2023', isActive: true },
    { id: 'CS-A-2022', classId: 'CS-A', name: '2022', isActive: true },
    
    // CS-B batches
    { id: 'CS-B-2024', classId: 'CS-B', name: '2024', isActive: true },
    { id: 'CS-B-2023', classId: 'CS-B', name: '2023', isActive: true },
    
    // CS-C batches
    { id: 'CS-C-2024', classId: 'CS-C', name: '2024', isActive: true },
    
    // IT-A batches
    { id: 'IT-A-2024', classId: 'IT-A', name: '2024', isActive: true },
    { id: 'IT-A-2023', classId: 'IT-A', name: '2023', isActive: true },
    
    // IT-B batches
    { id: 'IT-B-2024', classId: 'IT-B', name: '2024', isActive: true },
    
    // EC-A batches
    { id: 'EC-A-2024', classId: 'EC-A', name: '2024', isActive: true },
    { id: 'EC-A-2023', classId: 'EC-A', name: '2023', isActive: true },
    
    // EC-B batches
    { id: 'EC-B-2024', classId: 'EC-B', name: '2024', isActive: true },
    
    // ME-A batches
    { id: 'ME-A-2024', classId: 'ME-A', name: '2024', isActive: true },
    { id: 'ME-A-2023', classId: 'ME-A', name: '2023', isActive: true },
    
    // ME-B batches
    { id: 'ME-B-2024', classId: 'ME-B', name: '2024', isActive: true },
    
    // CE-A batches
    { id: 'CE-A-2024', classId: 'CE-A', name: '2024', isActive: true },
  ],

  faculty: [
    {
      id: 'faculty1',
      name: 'Dr. John Smith',
      email: 'faculty1@darshan.ac.in',
      role: 'faculty',
      branch: 'CS',
      isActive: true,
    },
    {
      id: 'faculty2',
      name: 'Prof. Jane Doe',
      email: 'faculty2@darshan.ac.in',
      role: 'faculty',
      branch: 'IT',
      isActive: true,
    },
    {
      id: 'faculty3',
      name: 'Dr. Mike Johnson',
      email: 'faculty3@darshan.ac.in',
      role: 'faculty',
      branch: 'EC',
      isActive: true,
    },
    {
      id: 'faculty4',
      name: 'Prof. Sarah Wilson',
      email: 'faculty4@darshan.ac.in',
      role: 'faculty',
      branch: 'ME',
      isActive: true,
    },
  ],

  students: [
    // CS-A 2024 students
    {
      id: 'student1',
      name: 'Alice Johnson',
      email: 'student1@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'CS2024001',
      branch: 'CS',
      classId: 'CS-A',
      batchId: 'CS-A-2024',
      isActive: true,
    },
    {
      id: 'student2',
      name: 'Bob Smith',
      email: 'student2@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'CS2024002',
      branch: 'CS',
      classId: 'CS-A',
      batchId: 'CS-A-2024',
      isActive: true,
    },
    {
      id: 'student3',
      name: 'Charlie Brown',
      email: 'student3@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'CS2024003',
      branch: 'CS',
      classId: 'CS-A',
      batchId: 'CS-A-2024',
      isActive: true,
    },
    
    // CS-A 2023 students
    {
      id: 'student4',
      name: 'Diana Prince',
      email: 'student4@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'CS2023001',
      branch: 'CS',
      classId: 'CS-A',
      batchId: 'CS-A-2023',
      isActive: true,
    },
    {
      id: 'student5',
      name: 'Eve Adams',
      email: 'student5@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'CS2023002',
      branch: 'CS',
      classId: 'CS-A',
      batchId: 'CS-A-2023',
      isActive: true,
    },
    
    // IT-A 2024 students
    {
      id: 'student6',
      name: 'Frank Miller',
      email: 'student6@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'IT2024001',
      branch: 'IT',
      classId: 'IT-A',
      batchId: 'IT-A-2024',
      isActive: true,
    },
    {
      id: 'student7',
      name: 'Grace Lee',
      email: 'student7@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'IT2024002',
      branch: 'IT',
      classId: 'IT-A',
      batchId: 'IT-A-2024',
      isActive: true,
    },
    
    // EC-A 2024 students
    {
      id: 'student8',
      name: 'Henry Davis',
      email: 'student8@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'EC2024001',
      branch: 'EC',
      classId: 'EC-A',
      batchId: 'EC-A-2024',
      isActive: true,
    },
    {
      id: 'student9',
      name: 'Ivy Chen',
      email: 'student9@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'EC2024002',
      branch: 'EC',
      classId: 'EC-A',
      batchId: 'EC-A-2024',
      isActive: true,
    },
    
    // ME-A 2024 students
    {
      id: 'student10',
      name: 'Jack Wilson',
      email: 'student10@darshan.ac.in',
      role: 'student',
      enrollmentNo: 'ME2024001',
      branch: 'ME',
      classId: 'ME-A',
      batchId: 'ME-A-2024',
      isActive: true,
    },
  ],
};

// Helper function to generate server seed
function generateServerSeed() {
  return crypto.randomBytes(32).toString('hex');
}

// Helper function to generate PIN hash
function generatePinHash(pin) {
  return crypto.createHash('sha256').update(pin).digest('hex');
}

// Helper function to generate device binding
function generateDeviceBinding() {
  const deviceUuid = crypto.randomBytes(16).toString('base64');
  const instIdHash = crypto.createHash('sha256')
    .update(`android|com.example.unimark|${deviceUuid}`)
    .digest('hex');
  
  return {
    instIdHash,
    platform: 'android',
    boundAt: admin.firestore.Timestamp.now(),
  };
}

// Seed branches
async function seedBranches() {
  console.log('Seeding branches...');
  const batch = db.batch();
  
  for (const branch of sampleData.branches) {
    const docRef = db.collection('branches').doc(branch.id);
    batch.set(docRef, {
      name: branch.name,
      createdAt: admin.firestore.Timestamp.now(),
      isActive: branch.isActive,
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleData.branches.length} branches`);
}

// Seed classes
async function seedClasses() {
  console.log('Seeding classes...');
  const batch = db.batch();
  
  for (const classData of sampleData.classes) {
    const docRef = db.collection('classes').doc(classData.id);
    batch.set(docRef, {
      branchId: classData.branchId,
      name: classData.name,
      createdAt: admin.firestore.Timestamp.now(),
      isActive: classData.isActive,
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleData.classes.length} classes`);
}

// Seed batches
async function seedBatches() {
  console.log('Seeding batches...');
  const batch = db.batch();
  
  for (const batchData of sampleData.batches) {
    const docRef = db.collection('batches').doc(batchData.id);
    batch.set(docRef, {
      classId: batchData.classId,
      name: batchData.name,
      createdAt: admin.firestore.Timestamp.now(),
      isActive: batchData.isActive,
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleData.batches.length} batches`);
}

// Seed faculty
async function seedFaculty() {
  console.log('Seeding faculty...');
  const batch = db.batch();
  
  for (const faculty of sampleData.faculty) {
    const docRef = db.collection('users').doc(faculty.id);
    batch.set(docRef, {
      name: faculty.name,
      email: faculty.email,
      role: faculty.role,
      branch: faculty.branch,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      isActive: faculty.isActive,
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleData.faculty.length} faculty members`);
}

// Seed students
async function seedStudents() {
  console.log('Seeding students...');
  const batch = db.batch();
  
  for (const student of sampleData.students) {
    const docRef = db.collection('users').doc(student.id);
    const deviceBinding = generateDeviceBinding();
    const pinHash = generatePinHash('1234'); // Default PIN for all students
    
    batch.set(docRef, {
      name: student.name,
      email: student.email,
      role: student.role,
      enrollmentNo: student.enrollmentNo,
      branch: student.branch,
      classId: student.classId,
      batchId: student.batchId,
      deviceBinding,
      pinHash,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      isActive: student.isActive,
    });
    
    // Create server seed for student
    const seedRef = db.collection('server_seeds').doc(student.id);
    batch.set(seedRef, {
      seed: generateServerSeed(),
      createdAt: admin.firestore.Timestamp.now(),
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${sampleData.students.length} students`);
}

// Seed sample sessions
async function seedSessions() {
  console.log('Seeding sample sessions...');
  const batch = db.batch();
  
  // Create a sample session for CS-A 2024
  const sessionId = 'sample-session-1';
  const sessionRef = db.collection('sessions').doc(sessionId);
  const now = admin.firestore.Timestamp.now();
  const expiresAt = new admin.firestore.Timestamp(now.seconds + 300, now.nanoseconds); // 5 minutes
  const editableUntil = new admin.firestore.Timestamp(now.seconds + 172800, now.nanoseconds); // 48 hours
  
  batch.set(sessionRef, {
    facultyId: 'faculty1',
    branchId: 'CS',
    classId: 'CS-A',
    batchIds: ['CS-A-2024'],
    subject: 'Data Structures',
    code: 123,
    nonce: crypto.randomBytes(16).toString('base64'),
    startAt: now,
    expiresAt,
    ttlSeconds: 300,
    status: 'open',
    editableUntil,
    facultyLocation: {
      lat: 23.0225, // Darshan University coordinates
      lng: 72.5714,
      accuracyM: 10,
    },
    gpsRadiusM: 500,
    stats: {
      presentCount: 0,
      totalCount: 3, // 3 students in CS-A 2024
    },
  });
  
  await batch.commit();
  console.log('✅ Seeded 1 sample session');
}

// Main seeding function
async function seedData() {
  try {
    console.log('🌱 Starting UniMark data seeding...\n');
    
    await seedBranches();
    await seedClasses();
    await seedBatches();
    await seedFaculty();
    await seedStudents();
    await seedSessions();
    
    console.log('\n🎉 Data seeding completed successfully!');
    console.log('\n📋 Sample Accounts:');
    console.log('Admin:');
    console.log('  ID: ADMIN404');
    console.log('  Password: ADMIN9090@@@@');
    console.log('\nFaculty:');
    console.log('  faculty1@darshan.ac.in');
    console.log('  faculty2@darshan.ac.in');
    console.log('  faculty3@darshan.ac.in');
    console.log('  faculty4@darshan.ac.in');
    console.log('\nStudents (PIN: 1234):');
    console.log('  student1@darshan.ac.in (CS2024001)');
    console.log('  student2@darshan.ac.in (CS2024002)');
    console.log('  student3@darshan.ac.in (CS2024003)');
    console.log('  student4@darshan.ac.in (CS2023001)');
    console.log('  student5@darshan.ac.in (CS2023002)');
    console.log('  student6@darshan.ac.in (IT2024001)');
    console.log('  student7@darshan.ac.in (IT2024002)');
    console.log('  student8@darshan.ac.in (EC2024001)');
    console.log('  student9@darshan.ac.in (EC2024002)');
    console.log('  student10@darshan.ac.in (ME2024001)');
    
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
}

// Run seeding if called directly
if (require.main === module) {
  seedData();
}

module.exports = { seedData, sampleData };
