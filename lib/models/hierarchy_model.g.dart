// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hierarchy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchModel _$BranchModelFromJson(Map<String, dynamic> json) => BranchModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$BranchModelToJson(BranchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
  id: json['id'] as String,
  branchId: json['branchId'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };

BatchModel _$BatchModelFromJson(Map<String, dynamic> json) => BatchModel(
  id: json['id'] as String,
  classId: json['classId'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$BatchModelToJson(BatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };

AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) =>
    AuditLogModel(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      sessionId: json['sessionId'] as String?,
      userId: json['userId'] as String?,
      ip: json['ip'] as String?,
      userAgent: json['userAgent'] as String?,
      details: json['details'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AuditLogModelToJson(AuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'ip': instance.ip,
      'userAgent': instance.userAgent,
      'details': instance.details,
      'createdAt': instance.createdAt.toIso8601String(),
    };
