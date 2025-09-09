import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { admin, faculty, student }

@JsonSerializable()
class DeviceBinding extends Equatable {
  final String instIdHash;
  final String platform;
  final DateTime boundAt;

  const DeviceBinding({
    required this.instIdHash,
    required this.platform,
    required this.boundAt,
  });

  factory DeviceBinding.fromJson(Map<String, dynamic> json) =>
      _$DeviceBindingFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceBindingToJson(this);

  factory DeviceBinding.fromFirestore(Map<String, dynamic> data) {
    return DeviceBinding(
      instIdHash: data['instIdHash'] ?? '',
      platform: data['platform'] ?? '',
      boundAt: (data['boundAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'instIdHash': instIdHash,
      'platform': platform,
      'boundAt': Timestamp.fromDate(boundAt),
    };
  }

  @override
  List<Object?> get props => [instIdHash, platform, boundAt];
}

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? enrollmentNo;
  final String? enrollmentNumber; // Legacy field for backward compatibility
  final String? branch;
  final String? classId;
  final String? className; // Legacy field for backward compatibility
  final String? batchId;
  final String? batch; // Legacy field for backward compatibility
  final DeviceBinding? deviceBinding;
  final String? pinHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool? tempPassword; // For faculty - true until password is reset
  final String? lastLocation; // For faculty - last known location

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.enrollmentNo,
    this.enrollmentNumber,
    this.branch,
    this.classId,
    this.className,
    this.batchId,
    this.batch,
    this.deviceBinding,
    this.pinHash,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.tempPassword,
    this.lastLocation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.student,
      ),
      enrollmentNo: data['enrollmentNo'],
      enrollmentNumber: data['enrollmentNumber'],
      branch: data['branch'],
      classId: data['classId'],
      className: data['className'],
      batchId: data['batchId'],
      batch: data['batch'],
      deviceBinding: data['deviceBinding'] != null
          ? DeviceBinding.fromFirestore(data['deviceBinding'])
          : null,
      pinHash: data['pinHash'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      tempPassword: data['tempPassword'],
      lastLocation: data['lastLocation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'enrollmentNo': enrollmentNo,
      'enrollmentNumber': enrollmentNumber,
      'branch': branch,
      'classId': classId,
      'className': className,
      'batchId': batchId,
      'batch': batch,
      'deviceBinding': deviceBinding?.toFirestore(),
      'pinHash': pinHash,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'tempPassword': tempPassword,
      'lastLocation': lastLocation,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? enrollmentNo,
    String? enrollmentNumber,
    String? branch,
    String? classId,
    String? className,
    String? batchId,
    String? batch,
    DeviceBinding? deviceBinding,
    String? pinHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? tempPassword,
    String? lastLocation,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      branch: branch ?? this.branch,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      batchId: batchId ?? this.batchId,
      batch: batch ?? this.batch,
      deviceBinding: deviceBinding ?? this.deviceBinding,
      pinHash: pinHash ?? this.pinHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tempPassword: tempPassword ?? this.tempPassword,
      lastLocation: lastLocation ?? this.lastLocation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        enrollmentNo,
        enrollmentNumber,
        branch,
        classId,
        className,
        batchId,
        batch,
        deviceBinding,
        pinHash,
        createdAt,
        updatedAt,
        isActive,
        tempPassword,
        lastLocation,
      ];
}
