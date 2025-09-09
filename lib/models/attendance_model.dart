import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../services/location_service.dart' as location_service;
import '../services/location_service.dart';

part 'attendance_model.g.dart';

enum AttendanceResult {
  accepted,
  rejected,
  pending,
}

@JsonSerializable()
class AttendanceModel extends Equatable {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentUid; // Add studentUid property
  final DateTime markedAt;
  final DateTime submittedAt; // Add submittedAt property
  final location_service.LocationData location;
  final double distance; // Distance from session location in meters
  final bool isPresent;
  final AttendanceResult result; // Add result property
  final String? reason; // Add reason property
  final String? editedBy; // Add editedBy property
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentUid,
    required this.markedAt,
    required this.submittedAt,
    required this.location,
    required this.distance,
    required this.isPresent,
    required this.result,
    this.reason,
    this.editedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentUid: data['studentUid'] ?? data['studentId'] ?? '',
      markedAt: (data['markedAt'] as Timestamp).toDate(),
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? (data['markedAt'] as Timestamp).toDate(),
      location: location_service.LocationData.fromFirestore(data['location']),
      distance: (data['distance'] ?? 0).toDouble(),
      isPresent: data['isPresent'] ?? false,
      result: _parseAttendanceResult(data['result'] ?? data['status']),
      reason: data['reason'],
      editedBy: data['editedBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static AttendanceResult _parseAttendanceResult(dynamic value) {
    if (value == null) return AttendanceResult.pending;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'accepted':
        case 'present':
          return AttendanceResult.accepted;
        case 'rejected':
        case 'absent':
          return AttendanceResult.rejected;
        default:
          return AttendanceResult.pending;
      }
    }
    return AttendanceResult.pending;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentUid': studentUid,
      'markedAt': Timestamp.fromDate(markedAt),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'location': location.toFirestore(),
      'distance': distance,
      'isPresent': isPresent,
      'result': result.name,
      'reason': reason,
      'editedBy': editedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? studentUid,
    DateTime? markedAt,
    DateTime? submittedAt,
    location_service.LocationData? location,
    double? distance,
    bool? isPresent,
    AttendanceResult? result,
    String? reason,
    String? editedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      studentUid: studentUid ?? this.studentUid,
      markedAt: markedAt ?? this.markedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      isPresent: isPresent ?? this.isPresent,
      result: result ?? this.result,
      reason: reason ?? this.reason,
      editedBy: editedBy ?? this.editedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        studentId,
        studentUid,
        markedAt,
        submittedAt,
        location,
        distance,
        isPresent,
        result,
        reason,
        editedBy,
        createdAt,
        updatedAt,
      ];
}