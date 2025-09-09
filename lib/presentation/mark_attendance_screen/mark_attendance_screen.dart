import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart' as location_service;
import 'widgets/attendance_code_input_widget.dart';
import 'widgets/location_verification_widget.dart';
import 'widgets/session_info_widget.dart';
import 'widgets/attendance_submission_widget.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final SessionModel session;
  final UserModel currentUser;

  const MarkAttendanceScreen({
    super.key,
    required this.session,
    required this.currentUser,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final location_service.LocationService _locationService = location_service.LocationService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLocationVerified = false;
  bool _isCodeVerified = false;
  location_service.LocationData? _currentLocation;
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
      final locationResult = await _locationService.getCurrentLocation();
      if (locationResult.isSuccess && locationResult.location != null) {
        setState(() {
          _currentLocation = locationResult.location!;
          _isLocationVerified = _verifyLocation(locationResult.location!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = locationResult.error ?? 'Failed to get location';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  bool _verifyLocation(location_service.LocationData location) {
    return _locationService.isWithinRadius(
      location,
      widget.session.facultyLocation,
      widget.session.gpsRadiusM.toDouble(),
    );
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
    if (!_isCodeVerified || !_isLocationVerified || _currentLocation == null) {
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
      final hasSubmitted = await _attendanceService.hasAlreadySubmitted(widget.session.id);

      if (hasSubmitted) {
        Fluttertoast.showToast(
          msg: 'You have already marked attendance for this session.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppTheme.warningLight,
          textColor: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }

      // Use attendance service for submission
      final result = await _attendanceService.submitAttendance(
        sessionId: widget.session.id,
        responseCode: int.parse(_codeController.text),
        useBiometric: false,
      );

      if (result.isSuccess) {
        Fluttertoast.showToast(
          msg: result.message ?? 'Attendance marked successfully!',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppTheme.successLight,
          textColor: Colors.white,
        );

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        Fluttertoast.showToast(
          msg: result.error ?? 'Failed to mark attendance',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppTheme.errorLight,
          textColor: Colors.white,
        );
      }
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
                sessionLocation: LocationData(
                  latitude: widget.session.facultyLocation.lat,
                  longitude: widget.session.facultyLocation.lng,
                ),
                currentLocation: _currentLocation != null 
                    ? LocationData(
                        latitude: _currentLocation!.latitude,
                        longitude: _currentLocation!.longitude,
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
