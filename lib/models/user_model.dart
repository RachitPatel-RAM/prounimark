import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, faculty, student }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? enrollmentNumber;
  final String? branch;
  final String? className;
  final String? batch;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.enrollmentNumber,
    this.branch,
    this.className,
    this.batch,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

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
      enrollmentNumber: data['enrollmentNumber'],
      branch: data['branch'],
      className: data['className'],
      batch: data['batch'],
      deviceId: data['deviceId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'enrollmentNumber': enrollmentNumber,
      'branch': branch,
      'className': className,
      'batch': batch,
      'deviceId': deviceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? enrollmentNumber,
    String? branch,
    String? className,
    String? batch,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      batch: batch ?? this.batch,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
