import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../services/location_service.dart' as location_service;
import '../services/location_service.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel extends Equatable {
  final String id;
  final String facultyId;
  final String course;
  final String className;
  final String? batchName;
  final String? sessionCode;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> studentsPresent;
  final location_service.LocationData gpsLocation;
  final double radius; // in meters
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionModel({
    required this.id,
    required this.facultyId,
    required this.course,
    required this.className,
    this.batchName,
    this.sessionCode,
    required this.startTime,
    this.endTime,
    required this.studentsPresent,
    required this.gpsLocation,
    required this.radius,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      facultyId: data['facultyId'] ?? '',
      course: data['course'] ?? '',
      className: data['className'] ?? '',
      batchName: data['batchName'],
      sessionCode: data['sessionCode'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      studentsPresent: List<String>.from(data['studentsPresent'] ?? []),
      gpsLocation: location_service.LocationData.fromFirestore(data['gpsLocation']),
      radius: (data['radius'] ?? 500).toDouble(),
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'facultyId': facultyId,
      'course': course,
      'className': className,
      'batchName': batchName,
      'sessionCode': sessionCode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'studentsPresent': studentsPresent,
      'gpsLocation': gpsLocation.toFirestore(),
      'radius': radius,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SessionModel copyWith({
    String? id,
    String? facultyId,
    String? course,
    String? className,
    String? batchName,
    String? sessionCode,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? studentsPresent,
    location_service.LocationData? gpsLocation,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      course: course ?? this.course,
      className: className ?? this.className,
      batchName: batchName ?? this.batchName,
      sessionCode: sessionCode ?? this.sessionCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      studentsPresent: studentsPresent ?? this.studentsPresent,
      gpsLocation: gpsLocation ?? this.gpsLocation,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        facultyId,
        course,
        className,
        batchName,
        sessionCode,
        startTime,
        endTime,
        studentsPresent,
        gpsLocation,
        radius,
        isActive,
        createdAt,
        updatedAt,
      ];
}