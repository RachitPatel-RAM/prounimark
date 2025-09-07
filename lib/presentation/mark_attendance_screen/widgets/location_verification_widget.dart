import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/session_model.dart';

class LocationVerificationWidget extends StatelessWidget {
  final bool isLocationVerified;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRetry;
  final LocationData sessionLocation;
  final LocationData? currentLocation;
  final int radius;

  const LocationVerificationWidget({
    Key? key,
    required this.isLocationVerified,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.sessionLocation,
    this.currentLocation,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isLocationVerified ? AppTheme.successLight : AppTheme.errorLight,
                  size: 24.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Location Verification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                    ),
                  )
                else
                  Icon(
                    isLocationVerified ? Icons.check_circle : Icons.error,
                    color: isLocationVerified ? AppTheme.successLight : AppTheme.errorLight,
                    size: 24.sp,
                  ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            if (isLocationVerified) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successLight,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Location verified! You are within the allowed radius.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (errorMessage.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorLight.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: AppTheme.errorLight,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Location verification failed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.errorLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh, size: 16.sp),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorLight,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: AppTheme.warningLight,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Verifying your location...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warningLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 3.h),
            
            // Location Details
            _buildLocationDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        _buildLocationRow(
          context,
          'Session Location',
          '${sessionLocation.latitude.toStringAsFixed(6)}, ${sessionLocation.longitude.toStringAsFixed(6)}',
        ),
        
        if (currentLocation != null) ...[
          SizedBox(height: 1.h),
          _buildLocationRow(
            context,
            'Your Location',
            '${currentLocation!.latitude.toStringAsFixed(6)}, ${currentLocation!.longitude.toStringAsFixed(6)}',
          ),
          
          SizedBox(height: 1.h),
          _buildLocationRow(
            context,
            'Distance',
            currentLocation != null 
                ? '${sessionLocation.distanceTo(currentLocation!).toStringAsFixed(0)} meters'
                : 'Calculating...',
          ),
        ],
        
        SizedBox(height: 1.h),
        _buildLocationRow(
          context,
          'Allowed Radius',
          '$radius meters',
        ),
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
