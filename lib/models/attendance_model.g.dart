// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      studentId: json['studentId'] as String,
      studentUid: json['studentUid'] as String,
      markedAt: DateTime.parse(json['markedAt'] as String),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      distance: (json['distance'] as num).toDouble(),
      isPresent: json['isPresent'] as bool,
      result: $enumDecode(_$AttendanceResultEnumMap, json['result']),
      reason: json['reason'] as String?,
      editedBy: json['editedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'studentId': instance.studentId,
      'studentUid': instance.studentUid,
      'markedAt': instance.markedAt.toIso8601String(),
      'submittedAt': instance.submittedAt.toIso8601String(),
      'location': instance.location,
      'distance': instance.distance,
      'isPresent': instance.isPresent,
      'result': _$AttendanceResultEnumMap[instance.result]!,
      'reason': instance.reason,
      'editedBy': instance.editedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceResultEnumMap = {
  AttendanceResult.accepted: 'accepted',
  AttendanceResult.rejected: 'rejected',
  AttendanceResult.pending: 'pending',
};
