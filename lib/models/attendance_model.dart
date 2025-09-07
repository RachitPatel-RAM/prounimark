import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

enum AttendanceResult { accepted, rejected }

@JsonSerializable()
class StudentLocation extends Equatable {
  final double lat;
  final double lng;
  final double accM;

  const StudentLocation({
    required this.lat,
    required this.lng,
    required this.accM,
  });

  factory StudentLocation.fromJson(Map<String, dynamic> json) =>
      _$StudentLocationFromJson(json);

  Map<String, dynamic> toJson() => _$StudentLocationToJson(this);

  factory StudentLocation.fromFirestore(Map<String, dynamic> data) {
    return StudentLocation(
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
      accM: data['accM'] ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lat': lat,
      'lng': lng,
      'accM': accM,
    };
  }

  @override
  List<Object?> get props => [lat, lng, accM];
}

@JsonSerializable()
class VerificationFlags extends Equatable {
  final bool timeOk;
  final bool codeOk;
  final bool deviceOk;
  final bool integrityOk;
  final bool locationOk;

  const VerificationFlags({
    required this.timeOk,
    required this.codeOk,
    required this.deviceOk,
    required this.integrityOk,
    required this.locationOk,
  });

  factory VerificationFlags.fromJson(Map<String, dynamic> json) =>
      _$VerificationFlagsFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationFlagsToJson(this);

  factory VerificationFlags.fromFirestore(Map<String, dynamic> data) {
    return VerificationFlags(
      timeOk: data['timeOk'] ?? false,
      codeOk: data['codeOk'] ?? false,
      deviceOk: data['deviceOk'] ?? false,
      integrityOk: data['integrityOk'] ?? false,
      locationOk: data['locationOk'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timeOk': timeOk,
      'codeOk': codeOk,
      'deviceOk': deviceOk,
      'integrityOk': integrityOk,
      'locationOk': locationOk,
    };
  }

  @override
  List<Object?> get props => [timeOk, codeOk, deviceOk, integrityOk, locationOk];
}

@JsonSerializable()
class AttendanceModel extends Equatable {
  final String id;
  final String sessionId;
  final String studentUid;
  final String enrollmentNo;
  final DateTime submittedAt;
  final int responseCode;
  final String deviceInstIdHash;
  final StudentLocation location;
  final VerificationFlags verified;
  final AttendanceResult result;
  final String? reason;
  final String? editedBy;
  final DateTime? editedAt;

  const AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentUid,
    required this.enrollmentNo,
    required this.submittedAt,
    required this.responseCode,
    required this.deviceInstIdHash,
    required this.location,
    required this.verified,
    required this.result,
    this.reason,
    this.editedBy,
    this.editedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentUid: data['studentUid'] ?? '',
      enrollmentNo: data['enrollmentNo'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      responseCode: data['responseCode'] ?? 0,
      deviceInstIdHash: data['deviceInstIdHash'] ?? '',
      location: StudentLocation.fromFirestore(data['location'] ?? {}),
      verified: VerificationFlags.fromFirestore(data['verified'] ?? {}),
      result: AttendanceResult.values.firstWhere(
        (e) => e.toString() == 'AttendanceResult.${data['result']}',
        orElse: () => AttendanceResult.rejected,
      ),
      reason: data['reason'],
      editedBy: data['editedBy'],
      editedAt: data['editedAt'] != null 
          ? (data['editedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentUid': studentUid,
      'enrollmentNo': enrollmentNo,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'responseCode': responseCode,
      'deviceInstIdHash': deviceInstIdHash,
      'location': location.toFirestore(),
      'verified': verified.toFirestore(),
      'result': result.toString().split('.').last,
      'reason': reason,
      'editedBy': editedBy,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? sessionId,
    String? studentUid,
    String? enrollmentNo,
    DateTime? submittedAt,
    int? responseCode,
    String? deviceInstIdHash,
    StudentLocation? location,
    VerificationFlags? verified,
    AttendanceResult? result,
    String? reason,
    String? editedBy,
    DateTime? editedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentUid: studentUid ?? this.studentUid,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      submittedAt: submittedAt ?? this.submittedAt,
      responseCode: responseCode ?? this.responseCode,
      deviceInstIdHash: deviceInstIdHash ?? this.deviceInstIdHash,
      location: location ?? this.location,
      verified: verified ?? this.verified,
      result: result ?? this.result,
      reason: reason ?? this.reason,
      editedBy: editedBy ?? this.editedBy,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        studentUid,
        enrollmentNo,
        submittedAt,
        responseCode,
        deviceInstIdHash,
        location,
        verified,
        result,
        reason,
        editedBy,
        editedAt,
      ];
}

// Legacy attendance status enum for backward compatibility
enum AttendanceStatus { present, absent, late }