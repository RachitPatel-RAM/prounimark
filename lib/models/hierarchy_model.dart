import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hierarchy_model.g.dart';

@JsonSerializable()
class BranchModel extends Equatable {
  final String id;
  final String name;
  final String description; // Added for backward compatibility
  final DateTime createdAt;
  final DateTime updatedAt; // Added for backward compatibility
  final bool isActive;

  const BranchModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  factory BranchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BranchModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  BranchModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt, isActive];
}

@JsonSerializable()
class ClassModel extends Equatable {
  final String id;
  final String branchId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const ClassModel({
    required this.id,
    required this.branchId,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClassModelToJson(this);

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      branchId: data['branchId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'branchId': branchId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  ClassModel copyWith({
    String? id,
    String? branchId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClassModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, branchId, name, description, createdAt, updatedAt, isActive];
}

@JsonSerializable()
class BatchModel extends Equatable {
  final String id;
  final String classId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const BatchModel({
    required this.id,
    required this.classId,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) =>
      _$BatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BatchModelToJson(this);

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BatchModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  BatchModel copyWith({
    String? id,
    String? classId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return BatchModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, classId, name, description, createdAt, updatedAt, isActive];
}

@JsonSerializable()
class AuditLogModel extends Equatable {
  final String id;
  final String eventType;
  final String? sessionId;
  final String? userId;
  final String? ip;
  final String? userAgent;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.eventType,
    this.sessionId,
    this.userId,
    this.ip,
    this.userAgent,
    required this.details,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuditLogModelToJson(this);

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      eventType: data['eventType'] ?? '',
      sessionId: data['sessionId'],
      userId: data['userId'],
      ip: data['ip'],
      userAgent: data['userAgent'],
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventType': eventType,
      'sessionId': sessionId,
      'userId': userId,
      'ip': ip,
      'userAgent': userAgent,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AuditLogModel copyWith({
    String? id,
    String? eventType,
    String? sessionId,
    String? userId,
    String? ip,
    String? userAgent,
    Map<String, dynamic>? details,
    DateTime? createdAt,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      ip: ip ?? this.ip,
      userAgent: userAgent ?? this.userAgent,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        sessionId,
        userId,
        ip,
        userAgent,
        details,
        createdAt,
      ];
}