// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceBinding _$DeviceBindingFromJson(Map<String, dynamic> json) =>
    DeviceBinding(
      instIdHash: json['instIdHash'] as String,
      platform: json['platform'] as String,
      boundAt: DateTime.parse(json['boundAt'] as String),
    );

Map<String, dynamic> _$DeviceBindingToJson(DeviceBinding instance) =>
    <String, dynamic>{
      'instIdHash': instance.instIdHash,
      'platform': instance.platform,
      'boundAt': instance.boundAt.toIso8601String(),
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  enrollmentNo: json['enrollmentNo'] as String?,
  enrollmentNumber: json['enrollmentNumber'] as String?,
  branch: json['branch'] as String?,
  classId: json['classId'] as String?,
  className: json['className'] as String?,
  batchId: json['batchId'] as String?,
  batch: json['batch'] as String?,
  deviceBinding: json['deviceBinding'] == null
      ? null
      : DeviceBinding.fromJson(json['deviceBinding'] as Map<String, dynamic>),
  pinHash: json['pinHash'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'enrollmentNo': instance.enrollmentNo,
  'enrollmentNumber': instance.enrollmentNumber,
  'branch': instance.branch,
  'classId': instance.classId,
  'className': instance.className,
  'batchId': instance.batchId,
  'batch': instance.batch,
  'deviceBinding': instance.deviceBinding,
  'pinHash': instance.pinHash,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.faculty: 'faculty',
  UserRole.student: 'student',
};
