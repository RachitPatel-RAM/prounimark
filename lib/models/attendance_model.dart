import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_model.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String enrollmentNumber;
  final AttendanceStatus status;
  final DateTime timestamp;
  final LocationData? location;
  final String? notes;
  final bool isEdited;
  final DateTime? editedAt;
  final String? editedBy;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.enrollmentNumber,
    required this.status,
    required this.timestamp,
    this.location,
    this.notes,
    this.isEdited = false,
    this.editedAt,
    this.editedBy,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      enrollmentNumber: data['enrollmentNumber'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${data['status']}',
        orElse: () => AttendanceStatus.absent,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'] != null 
          ? LocationData.fromMap(data['location']) 
          : null,
      notes: data['notes'],
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null 
          ? (data['editedAt'] as Timestamp).toDate() 
          : null,
      editedBy: data['editedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'enrollmentNumber': enrollmentNumber,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location?.toMap(),
      'notes': notes,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'editedBy': editedBy,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? studentName,
    String? enrollmentNumber,
    AttendanceStatus? status,
    DateTime? timestamp,
    LocationData? location,
    String? notes,
    bool? isEdited,
    DateTime? editedAt,
    String? editedBy,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      editedBy: editedBy ?? this.editedBy,
    );
  }
}
