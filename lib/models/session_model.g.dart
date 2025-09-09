// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  facultyId: json['facultyId'] as String,
  course: json['course'] as String,
  className: json['className'] as String,
  batchName: json['batchName'] as String?,
  sessionCode: json['sessionCode'] as String?,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  studentsPresent: (json['studentsPresent'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  gpsLocation: LocationData.fromJson(
    json['gpsLocation'] as Map<String, dynamic>,
  ),
  radius: (json['radius'] as num).toDouble(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'facultyId': instance.facultyId,
      'course': instance.course,
      'className': instance.className,
      'batchName': instance.batchName,
      'sessionCode': instance.sessionCode,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'studentsPresent': instance.studentsPresent,
      'gpsLocation': instance.gpsLocation,
      'radius': instance.radius,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
