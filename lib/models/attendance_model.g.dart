// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentLocation _$StudentLocationFromJson(Map<String, dynamic> json) =>
    StudentLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accM: (json['accM'] as num).toDouble(),
    );

Map<String, dynamic> _$StudentLocationToJson(StudentLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'accM': instance.accM,
    };

VerificationFlags _$VerificationFlagsFromJson(Map<String, dynamic> json) =>
    VerificationFlags(
      timeOk: json['timeOk'] as bool,
      codeOk: json['codeOk'] as bool,
      deviceOk: json['deviceOk'] as bool,
      integrityOk: json['integrityOk'] as bool,
      locationOk: json['locationOk'] as bool,
    );

Map<String, dynamic> _$VerificationFlagsToJson(VerificationFlags instance) =>
    <String, dynamic>{
      'timeOk': instance.timeOk,
      'codeOk': instance.codeOk,
      'deviceOk': instance.deviceOk,
      'integrityOk': instance.integrityOk,
      'locationOk': instance.locationOk,
    };

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      studentUid: json['studentUid'] as String,
      enrollmentNo: json['enrollmentNo'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      responseCode: (json['responseCode'] as num).toInt(),
      deviceInstIdHash: json['deviceInstIdHash'] as String,
      location: StudentLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      verified: VerificationFlags.fromJson(
        json['verified'] as Map<String, dynamic>,
      ),
      result: $enumDecode(_$AttendanceResultEnumMap, json['result']),
      reason: json['reason'] as String?,
      editedBy: json['editedBy'] as String?,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'studentUid': instance.studentUid,
      'enrollmentNo': instance.enrollmentNo,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'responseCode': instance.responseCode,
      'deviceInstIdHash': instance.deviceInstIdHash,
      'location': instance.location,
      'verified': instance.verified,
      'result': _$AttendanceResultEnumMap[instance.result]!,
      'reason': instance.reason,
      'editedBy': instance.editedBy,
      'editedAt': instance.editedAt?.toIso8601String(),
    };

const _$AttendanceResultEnumMap = {
  AttendanceResult.accepted: 'accepted',
  AttendanceResult.rejected: 'rejected',
};
