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
        borderRadius: BorderRadius.circular(16),
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
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Location Verification',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                _buildStatusIcon(),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (errorMessage.isNotEmpty)
              _buildErrorMessage(context)
            else if (currentLocation != null)
              _buildLocationInfo(context)
            else
              _buildNoLocationInfo(context),
            
            SizedBox(height: 2.h),
            
            if (!isLoading && errorMessage.isEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isLoading) {
      return SizedBox(
        width: 6.w,
        height: 6.w,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (isLocationVerified) {
      return Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 5.w,
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.cancel,
          color: Colors.red,
          size: 5.w,
        ),
      );
    }
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    final distance = currentLocation!.distanceTo(sessionLocation);
    final isWithinRadius = distance <= radius;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isWithinRadius 
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWithinRadius 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isWithinRadius ? Icons.check_circle : Icons.cancel,
                    color: isWithinRadius ? Colors.green : Colors.red,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      isWithinRadius 
                          ? 'You are within the attendance radius'
                          : 'You are outside the attendance radius',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isWithinRadius ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              _buildLocationDetail(
                context,
                'Your Location',
                '${currentLocation!.lat.toStringAsFixed(4)}, ${currentLocation!.lng.toStringAsFixed(4)}',
                'Accuracy: ${currentLocation!.accuracyM.toStringAsFixed(1)}m',
              ),
              
              SizedBox(height: 1.h),
              
              _buildLocationDetail(
                context,
                'Session Location',
                '${sessionLocation.lat.toStringAsFixed(4)}, ${sessionLocation.lng.toStringAsFixed(4)}',
                'Radius: ${radius}m',
              ),
              
              SizedBox(height: 1.h),
              
              _buildLocationDetail(
                context,
                'Distance',
                '${distance.toStringAsFixed(1)}m',
                isWithinRadius ? 'Within range' : 'Outside range',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetail(
    BuildContext context,
    String label,
    String value,
    String subtitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoLocationInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            color: AppTheme.textSecondaryLight,
            size: 8.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Location not available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please enable location services and try again',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}