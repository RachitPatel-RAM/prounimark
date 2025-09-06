import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/batch_selection_widget.dart';
import './widgets/duration_picker_widget.dart';
import './widgets/location_section_widget.dart';
import './widgets/session_settings_widget.dart';
import './widgets/subject_selection_widget.dart';

class CreateAttendanceSessionScreen extends StatefulWidget {
  const CreateAttendanceSessionScreen({Key? key}) : super(key: key);

  @override
  State<CreateAttendanceSessionScreen> createState() =>
      _CreateAttendanceSessionScreenState();
}

class _CreateAttendanceSessionScreenState
    extends State<CreateAttendanceSessionScreen> {
  // Form state variables
  String? _selectedSubject;
  List<String> _selectedBatches = [];
  int _durationMinutes = 5;
  Position? _currentLocation;
  bool _autoGenerateCode = true;
  bool _allowLateEntry = true;
  bool _enableNotifications = true;
  bool _preventDuplicates = true;
  bool _enableOfflineSync = false;
  String _customInstructions = "";

  // UI state variables
  bool _isCreatingSession = false;
  String? _validationError;

  // Form validation
  bool get _isFormValid {
    return _selectedSubject != null &&
        _selectedBatches.isNotEmpty &&
        _currentLocation != null &&
        _durationMinutes >= 1 &&
        _durationMinutes <= 60;
  }

  String? get _getValidationMessage {
    if (_selectedSubject == null) return "Please select a subject";
    if (_selectedBatches.isEmpty) return "Please select at least one batch";
    if (_currentLocation == null) return "Please set session location";
    if (_currentLocation != null && _currentLocation!.accuracy > 50) {
      return "GPS accuracy is poor. Please try again in an open area";
    }
    return null;
  }

  Future<void> _createSession() async {
    if (!_isFormValid) {
      setState(() {
        _validationError = _getValidationMessage;
      });
      return;
    }

    setState(() {
      _isCreatingSession = true;
      _validationError = null;
    });

    try {
      // Simulate session creation process
      await Future.delayed(const Duration(seconds: 2));

      // Generate session code if auto-generate is enabled
      String sessionCode = "";
      if (_autoGenerateCode) {
        sessionCode = _generateSessionCode();
      }

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Show success dialog with session code
      await _showSessionCreatedDialog(sessionCode);

      // Navigate back to faculty dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/faculty-dashboard');
      }
    } catch (e) {
      setState(() {
        _validationError = "Failed to create session. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSession = false;
        });
      }
    }
  }

  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        3, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _showSessionCreatedDialog(String sessionCode) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              "Session Created!",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getSuccessColor(true),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sessionCode.isNotEmpty) ...[
              Text(
                "Session Code:",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  sessionCode,
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
            Text(
              "Students can now mark their attendance using the session code and location verification.",
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Continue",
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Create Attendance Session",
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              "Configure your attendance session with GPS verification and secure access controls.",
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Subject Selection
                    SubjectSelectionWidget(
                      selectedSubject: _selectedSubject,
                      onSubjectChanged: (subject) {
                        setState(() {
                          _selectedSubject = subject;
                          _validationError = null;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Batch Selection
                    BatchSelectionWidget(
                      selectedBatches: _selectedBatches,
                      onBatchesChanged: (batches) {
                        setState(() {
                          _selectedBatches = batches;
                          _validationError = null;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Duration Picker
                    DurationPickerWidget(
                      durationMinutes: _durationMinutes,
                      onDurationChanged: (duration) {
                        setState(() {
                          _durationMinutes = duration;
                          _validationError = null;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Location Section
                    LocationSectionWidget(
                      currentLocation: _currentLocation,
                      onLocationChanged: (location) {
                        setState(() {
                          _currentLocation = location;
                          _validationError = null;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Session Settings
                    SessionSettingsWidget(
                      autoGenerateCode: _autoGenerateCode,
                      allowLateEntry: _allowLateEntry,
                      enableNotifications: _enableNotifications,
                      onAutoGenerateChanged: (value) {
                        setState(() {
                          _autoGenerateCode = value;
                        });
                      },
                      onLateEntryChanged: (value) {
                        setState(() {
                          _allowLateEntry = value;
                        });
                      },
                      onNotificationsChanged: (value) {
                        setState(() {
                          _enableNotifications = value;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Advanced Options
                    AdvancedOptionsWidget(
                      preventDuplicates: _preventDuplicates,
                      enableOfflineSync: _enableOfflineSync,
                      customInstructions: _customInstructions,
                      onPreventDuplicatesChanged: (value) {
                        setState(() {
                          _preventDuplicates = value;
                        });
                      },
                      onOfflineSyncChanged: (value) {
                        setState(() {
                          _enableOfflineSync = value;
                        });
                      },
                      onInstructionsChanged: (instructions) {
                        setState(() {
                          _customInstructions = instructions;
                        });
                      },
                    ),

                    SizedBox(height: 10.h), // Extra space for bottom button
                  ],
                ),
              ),
            ),

            // Bottom Action Area
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Validation Error
                  if (_validationError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.getErrorColor(true).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppTheme.getErrorColor(true)
                              .withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error',
                            color: AppTheme.getErrorColor(true),
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _validationError!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.getErrorColor(true),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Create Session Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isCreatingSession ? null : _createSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onPrimary,
                        elevation: _isFormValid ? 2.0 : 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isCreatingSession
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  "Creating Session...",
                                  style: AppTheme
                                      .lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'add_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  "Create Session",
                                  style: AppTheme
                                      .lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
