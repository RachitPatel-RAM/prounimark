import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';

part 'session_model.g.dart';

enum SessionStatus { open, closed, locked }

@JsonSerializable()
class FacultyLocation extends Equatable {
  final double lat;
  final double lng;
  final double accuracyM;

  const FacultyLocation({
    required this.lat,
    required this.lng,
    required this.accuracyM,
  });

  factory FacultyLocation.fromJson(Map<String, dynamic> json) =>
      _$FacultyLocationFromJson(json);

  Map<String, dynamic> toJson() => _$FacultyLocationToJson(this);

  factory FacultyLocation.fromFirestore(Map<String, dynamic> data) {
    return FacultyLocation(
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
      accuracyM: data['accuracyM'] ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lat': lat,
      'lng': lng,
      'accuracyM': accuracyM,
    };
  }

  @override
  List<Object?> get props => [lat, lng, accuracyM];
}

@JsonSerializable()
class SessionStats extends Equatable {
  final int presentCount;
  final int totalCount;

  const SessionStats({
    required this.presentCount,
    required this.totalCount,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) =>
      _$SessionStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatsToJson(this);

  factory SessionStats.fromFirestore(Map<String, dynamic> data) {
    return SessionStats(
      presentCount: data['presentCount'] ?? 0,
      totalCount: data['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'presentCount': presentCount,
      'totalCount': totalCount,
    };
  }

  @override
  List<Object?> get props => [presentCount, totalCount];
}

@JsonSerializable()
class SessionModel extends Equatable {
  final String id;
  final String facultyId;
  final String branchId;
  final String classId;
  final List<String> batchIds;
  final String subject;
  final int code; // 3-digit code (0-999)
  final String nonce; // random base64
  final DateTime startAt;
  final DateTime expiresAt;
  final int ttlSeconds;
  final SessionStatus status;
  final DateTime editableUntil;
  final FacultyLocation facultyLocation;
  final int gpsRadiusM;
  final SessionStats stats;

  const SessionModel({
    required this.id,
    required this.facultyId,
    required this.branchId,
    required this.classId,
    required this.batchIds,
    required this.subject,
    required this.code,
    required this.nonce,
    required this.startAt,
    required this.expiresAt,
    required this.ttlSeconds,
    required this.status,
    required this.editableUntil,
    required this.facultyLocation,
    required this.gpsRadiusM,
    required this.stats,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      facultyId: data['facultyId'] ?? '',
      branchId: data['branchId'] ?? '',
      classId: data['classId'] ?? '',
      batchIds: List<String>.from(data['batchIds'] ?? []),
      subject: data['subject'] ?? '',
      code: data['code'] ?? 0,
      nonce: data['nonce'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      ttlSeconds: data['ttlSeconds'] ?? 300, // 5 minutes default
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == 'SessionStatus.${data['status']}',
        orElse: () => SessionStatus.open,
      ),
      editableUntil: (data['editableUntil'] as Timestamp).toDate(),
      facultyLocation: FacultyLocation.fromFirestore(data['facultyLocation'] ?? {}),
      gpsRadiusM: data['gpsRadiusM'] ?? 500,
      stats: SessionStats.fromFirestore(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'facultyId': facultyId,
      'branchId': branchId,
      'classId': classId,
      'batchIds': batchIds,
      'subject': subject,
      'code': code,
      'nonce': nonce,
      'startAt': Timestamp.fromDate(startAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'ttlSeconds': ttlSeconds,
      'status': status.toString().split('.').last,
      'editableUntil': Timestamp.fromDate(editableUntil),
      'facultyLocation': facultyLocation.toFirestore(),
      'gpsRadiusM': gpsRadiusM,
      'stats': stats.toFirestore(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? facultyId,
    String? branchId,
    String? classId,
    List<String>? batchIds,
    String? subject,
    int? code,
    String? nonce,
    DateTime? startAt,
    DateTime? expiresAt,
    int? ttlSeconds,
    SessionStatus? status,
    DateTime? editableUntil,
    FacultyLocation? facultyLocation,
    int? gpsRadiusM,
    SessionStats? stats,
  }) {
    return SessionModel(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      branchId: branchId ?? this.branchId,
      classId: classId ?? this.classId,
      batchIds: batchIds ?? this.batchIds,
      subject: subject ?? this.subject,
      code: code ?? this.code,
      nonce: nonce ?? this.nonce,
      startAt: startAt ?? this.startAt,
      expiresAt: expiresAt ?? this.expiresAt,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      status: status ?? this.status,
      editableUntil: editableUntil ?? this.editableUntil,
      facultyLocation: facultyLocation ?? this.facultyLocation,
      gpsRadiusM: gpsRadiusM ?? this.gpsRadiusM,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        facultyId,
        branchId,
        classId,
        batchIds,
        subject,
        code,
        nonce,
        startAt,
        expiresAt,
        ttlSeconds,
        status,
        editableUntil,
        facultyLocation,
        gpsRadiusM,
        stats,
      ];
}

// Legacy LocationData class for backward compatibility
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
    final double lat1Rad = latitude * (pi / 180);
    final double lat2Rad = other.latitude * (pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (pi / 180);
    final double deltaLngRad = (other.longitude - longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}