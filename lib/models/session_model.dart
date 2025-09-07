import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SessionModel {
  final String id;
  final String facultyId;
  final String facultyName;
  final String branch;
  final String className;
  final List<String> batches;
  final String subject;
  final String code;
  final LocationData location;
  final int radius; // in meters
  final bool isActive;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessionModel({
    required this.id,
    required this.facultyId,
    required this.facultyName,
    required this.branch,
    required this.className,
    required this.batches,
    required this.subject,
    required this.code,
    required this.location,
    this.radius = 500,
    this.isActive = true,
    required this.startTime,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      branch: data['branch'] ?? '',
      className: data['className'] ?? '',
      batches: List<String>.from(data['batches'] ?? []),
      subject: data['subject'] ?? '',
      code: data['code'] ?? '',
      location: LocationData.fromMap(data['location'] ?? {}),
      radius: data['radius'] ?? 500,
      isActive: data['isActive'] ?? true,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'facultyId': facultyId,
      'facultyName': facultyName,
      'branch': branch,
      'className': className,
      'batches': batches,
      'subject': subject,
      'code': code,
      'location': location.toMap(),
      'radius': radius,
      'isActive': isActive,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SessionModel copyWith({
    String? id,
    String? facultyId,
    String? facultyName,
    String? branch,
    String? className,
    List<String>? batches,
    String? subject,
    String? code,
    LocationData? location,
    int? radius,
    bool? isActive,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      branch: branch ?? this.branch,
      className: className ?? this.className,
      batches: batches ?? this.batches,
      subject: subject ?? this.subject,
      code: code ?? this.code,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  double distanceTo(LocationData other) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double lat1Rad = latitude * (3.14159265359 / 180);
    final double lat2Rad = other.latitude * (3.14159265359 / 180);
    final double deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180);
    final double deltaLngRad = (other.longitude - longitude) * (3.14159265359 / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}
