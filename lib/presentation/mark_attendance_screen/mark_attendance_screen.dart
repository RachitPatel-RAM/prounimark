import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../models/session_model.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../services/attendance_service.dart';
import 'widgets/attendance_code_input_widget.dart';
import 'widgets/location_verification_widget.dart';
import 'widgets/session_info_widget.dart';
import 'widgets/attendance_submission_widget.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final SessionModel session;
  final UserModel currentUser;

  const MarkAttendanceScreen({
    Key? key,
    required this.session,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLocationVerified = false;
  bool _isCodeVerified = false;
  Position? _currentPosition;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them to mark attendance.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are required to mark attendance.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.';
        });
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check location permission: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _firebaseService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLocationVerified = _verifyLocation(position);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  bool _verifyLocation(Position position) {
    if (_currentPosition == null) return false;
    
    final studentLocation = LocationData(
      lat: position.latitude,
      lng: position.longitude,
      accuracyM: position.accuracy,
    );
    
    final distance = studentLocation.distanceTo(widget.session.facultyLocation);
    return distance <= widget.session.gpsRadiusM;
  }

  void _verifyCode(String code) {
    setState(() {
      _isCodeVerified = code == widget.session.code.toString().padLeft(3, '0');
      if (!_isCodeVerified) {
        _errorMessage = 'Invalid attendance code. Please check with your faculty.';
      } else {
        _errorMessage = '';
      }
    });
  }

  Future<void> _submitAttendance() async {
    if (!_isCodeVerified || !_isLocationVerified || _currentPosition == null) {
      Fluttertoast.showToast(
        msg: 'Please verify your location and attendance code first.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already marked attendance
      final existingAttendance = await _firebaseService.getAttendance(
        widget.session.id,
        widget.currentUser.id,
      );

      if (existingAttendance != null) {
        Fluttertoast.showToast(
          msg: 'You have already marked attendance for this session.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppTheme.warningLight,
          textColor: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }

      // Create attendance record
      final attendance = AttendanceModel(
        sessionId: widget.session.id,
        studentUid: widget.currentUser.id,
        enrollmentNo: widget.currentUser.enrollmentNo ?? widget.currentUser.enrollmentNumber ?? '',
        submittedAt: DateTime.now(),
        responseCode: int.parse(_codeController.text),
        deviceInstIdHash: 'test-hash', // This should be generated from device info
        location: LocationData(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          accuracyM: _currentPosition!.accuracy,
        ),
        verified: VerifiedFlags(
          timeOk: true,
          codeOk: _isCodeVerified,
          deviceOk: true,
          integrityOk: true,
          locationOk: _isLocationVerified,
          biometricOk: true,
          pinOk: false,
        ),
        result: AttendanceResult.accepted,
      );

      // Use attendance service for submission
      final attendanceService = AttendanceService();
      final result = await attendanceService.submitAttendance(
        sessionId: widget.session.id,
        studentUid: widget.currentUser.id,
        responseCode: int.parse(_codeController.text),
        deviceInstIdHash: 'test-hash',
        platform: 'android',
        studentLocation: LocationData(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          accuracyM: _currentPosition!.accuracy,
        ),
        playIntegrityToken: 'test-token',
        appCheckToken: 'test-token',
      );

      Fluttertoast.showToast(
        msg: 'Attendance marked successfully!',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to mark attendance: $e',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimaryLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Information
              SessionInfoWidget(session: widget.session),
              
              SizedBox(height: 4.h),
              
              // Location Verification
              LocationVerificationWidget(
                isLocationVerified: _isLocationVerified,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onRetry: _getCurrentLocation,
                sessionLocation: widget.session.facultyLocation,
                currentLocation: _currentPosition != null 
                    ? LocationData(
                        lat: _currentPosition!.latitude,
                        lng: _currentPosition!.longitude,
                        accuracyM: _currentPosition!.accuracy,
                      )
                    : null,
                radius: widget.session.gpsRadiusM,
              ),
              
              SizedBox(height: 4.h),
              
              // Attendance Code Input
              AttendanceCodeInputWidget(
                controller: _codeController,
                isCodeVerified: _isCodeVerified,
                onCodeChanged: _verifyCode,
              ),
              
              SizedBox(height: 4.h),
              
              // Submit Button
              AttendanceSubmissionWidget(
                isLoading: _isLoading,
                isLocationVerified: _isLocationVerified,
                isCodeVerified: _isCodeVerified,
                onSubmit: _submitAttendance,
              ),
              
              SizedBox(height: 2.h),
              
              // Security Notice
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppTheme.primaryLight,
                      size: 20.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'This system uses GPS location and unique codes to prevent proxy attendance.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
