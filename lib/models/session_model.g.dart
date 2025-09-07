// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacultyLocation _$FacultyLocationFromJson(Map<String, dynamic> json) =>
    FacultyLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracyM: (json['accuracyM'] as num).toDouble(),
    );

Map<String, dynamic> _$FacultyLocationToJson(FacultyLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'accuracyM': instance.accuracyM,
    };

SessionStats _$SessionStatsFromJson(Map<String, dynamic> json) => SessionStats(
  presentCount: (json['presentCount'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$SessionStatsToJson(SessionStats instance) =>
    <String, dynamic>{
      'presentCount': instance.presentCount,
      'totalCount': instance.totalCount,
    };

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  facultyId: json['facultyId'] as String,
  branchId: json['branchId'] as String,
  classId: json['classId'] as String,
  batchIds: (json['batchIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  subject: json['subject'] as String,
  code: (json['code'] as num).toInt(),
  nonce: json['nonce'] as String,
  startAt: DateTime.parse(json['startAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  ttlSeconds: (json['ttlSeconds'] as num).toInt(),
  status: $enumDecode(_$SessionStatusEnumMap, json['status']),
  editableUntil: DateTime.parse(json['editableUntil'] as String),
  facultyLocation: FacultyLocation.fromJson(
    json['facultyLocation'] as Map<String, dynamic>,
  ),
  gpsRadiusM: (json['gpsRadiusM'] as num).toInt(),
  stats: SessionStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'facultyId': instance.facultyId,
      'branchId': instance.branchId,
      'classId': instance.classId,
      'batchIds': instance.batchIds,
      'subject': instance.subject,
      'code': instance.code,
      'nonce': instance.nonce,
      'startAt': instance.startAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'ttlSeconds': instance.ttlSeconds,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'editableUntil': instance.editableUntil.toIso8601String(),
      'facultyLocation': instance.facultyLocation,
      'gpsRadiusM': instance.gpsRadiusM,
      'stats': instance.stats,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.open: 'open',
  SessionStatus.closed: 'closed',
  SessionStatus.locked: 'locked',
};
