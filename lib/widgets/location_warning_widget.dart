import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';
import '../services/location_monitoring_service.dart';

class LocationWarningWidget extends StatefulWidget {
  final Widget child;
  final bool showWarning;
  final VoidCallback? onLocationRequested;

  const LocationWarningWidget({
    super.key,
    required this.child,
    this.showWarning = true,
    this.onLocationRequested,
  });

  @override
  State<LocationWarningWidget> createState() => _LocationWarningWidgetState();
}

class _LocationWarningWidgetState extends State<LocationWarningWidget> {
  final LocationMonitoringService _locationService = LocationMonitoringService();
  bool _isLocationEnabled = false;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _locationService.addLocationListener(_onLocationStatusChanged);
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationService.removeLocationListener(_onLocationStatusChanged);
    super.dispose();
  }

  void _onLocationStatusChanged() {
    setState(() {
      _isLocationEnabled = _locationService.isLocationEnabled;
      _showWarning = !_isLocationEnabled && widget.showWarning;
    });
  }

  Future<void> _checkLocationStatus() async {
    setState(() {
      _isLocationEnabled = _locationService.isLocationEnabled;
      _showWarning = !_isLocationEnabled && widget.showWarning;
    });
  }

  Future<void> _requestLocationAccess() async {
    final success = await _locationService.requestLocationAccess();
    if (success) {
      setState(() {
        _isLocationEnabled = true;
        _showWarning = false;
      });
      widget.onLocationRequested?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showWarning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(2.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.error,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off,
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Required',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Location must be enabled to use UniMark. Please turn on location services.',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: _requestLocationAccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    ),
                    child: Text('Enable'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LocationRequiredDialog extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const LocationRequiredDialog({
    super.key,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.location_off,
            color: AppTheme.lightTheme.colorScheme.error,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text('Location Required'),
        ],
      ),
      content: Text(
        'Location must be enabled to use UniMark. Please turn on location services in your device settings to continue.',
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text('Cancel'),
          ),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text('Check Again'),
        ),
      ],
    );
  }
}
