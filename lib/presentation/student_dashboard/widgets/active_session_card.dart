import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActiveSessionCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final VoidCallback onMarkAttendance;
  final bool isLocationEnabled;
  final double? locationAccuracy;

  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.onMarkAttendance,
    required this.isLocationEnabled,
    this.locationAccuracy,
  });

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
  final TextEditingController _sessionCodeController = TextEditingController();
  bool _isCodeValid = false;

  @override
  void dispose() {
    _sessionCodeController.dispose();
    super.dispose();
  }

  void _validateSessionCode(String code) {
    setState(() {
      _isCodeValid = code.length == 3 && code == widget.session['code'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = widget.session['timeRemaining'] as int? ?? 0;
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Session',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                    Text(
                      widget.session['subject'] as String? ?? 'Unknown Subject',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: timeRemaining > 300
                      ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
                      : AppTheme.getWarningColor(true).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: timeRemaining > 300
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.getWarningColor(true),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Faculty: ${widget.session['faculty'] as String? ?? 'Unknown'}',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName:
                    widget.isLocationEnabled ? 'location_on' : 'location_off',
                color: widget.isLocationEnabled
                    ? AppTheme.getSuccessColor(true)
                    : AppTheme.getErrorColor(true),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  widget.isLocationEnabled
                      ? 'Location: ${widget.locationAccuracy != null ? '±${widget.locationAccuracy!.toInt()}m' : 'Enabled'}'
                      : 'Location: Disabled',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: widget.isLocationEnabled
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.getErrorColor(true),
                  ),
                ),
              ),
              if (!widget.isLocationEnabled)
                TextButton(
                  onPressed: () {
                    // Navigate to settings
                  },
                  child: Text(
                    'Enable',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Session Code',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: _sessionCodeController,
                  onChanged: _validateSessionCode,
                  maxLength: 3,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '000',
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: (_isCodeValid && widget.isLocationEnabled)
                  ? widget.onMarkAttendance
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Mark Attendance',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
