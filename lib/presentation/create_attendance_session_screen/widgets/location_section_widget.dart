import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class LocationSectionWidget extends StatefulWidget {
  final Position? currentLocation;
  final Function(Position?) onLocationChanged;

  const LocationSectionWidget({
    Key? key,
    this.currentLocation,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<LocationSectionWidget> createState() => _LocationSectionWidgetState();
}

class _LocationSectionWidgetState extends State<LocationSectionWidget> {
  bool _isLoadingLocation = false;
  String? _locationError;
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _updateCircles();
    }
  }

  void _updateCircles() {
    if (widget.currentLocation != null) {
      setState(() {
        _circles = {
          Circle(
            circleId: const CircleId('attendance_radius'),
            center: LatLng(
              widget.currentLocation!.latitude,
              widget.currentLocation!.longitude,
            ),
            radius: 500, // 500 meter radius
            fillColor: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            strokeColor: AppTheme.lightTheme.primaryColor,
            strokeWidth: 2,
          ),
        };
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      widget.onLocationChanged(position);
      _updateCircles();

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            16.0,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  String _getAccuracyText() {
    if (widget.currentLocation == null) return "No location";

    final accuracy = widget.currentLocation!.accuracy;
    if (accuracy <= 10) return "Excellent (±${accuracy.toStringAsFixed(0)}m)";
    if (accuracy <= 20) return "Good (±${accuracy.toStringAsFixed(0)}m)";
    if (accuracy <= 50) return "Fair (±${accuracy.toStringAsFixed(0)}m)";
    return "Poor (±${accuracy.toStringAsFixed(0)}m)";
  }

  Color _getAccuracyColor() {
    if (widget.currentLocation == null)
      return AppTheme.lightTheme.colorScheme.onSurfaceVariant;

    final accuracy = widget.currentLocation!.accuracy;
    if (accuracy <= 10) return AppTheme.getSuccessColor(true);
    if (accuracy <= 20) return AppTheme.getWarningColor(true);
    return AppTheme.getErrorColor(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Session Location",
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "Students must be within 500m radius",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'my_location',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 18,
                        ),
                  label: Text(
                    _isLoadingLocation ? "Getting..." : "Use Current",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                ),
              ],
            ),
          ),

          // Location Info
          if (widget.currentLocation != null) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Coordinates
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'place',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          "${widget.currentLocation!.latitude.toStringAsFixed(6)}, ${widget.currentLocation!.longitude.toStringAsFixed(6)}",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Accuracy
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'gps_fixed',
                        color: _getAccuracyColor(),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Accuracy: ${_getAccuracyText()}",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getAccuracyColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Error Message
          if (_locationError != null) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
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
                      _locationError!,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getErrorColor(true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Map Preview
          if (widget.currentLocation != null) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.dividerColor,
            ),
            Container(
              height: 25.h,
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.currentLocation!.latitude,
                      widget.currentLocation!.longitude,
                    ),
                    zoom: 16.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  circles: _circles,
                  markers: {
                    Marker(
                      markerId: const MarkerId('session_location'),
                      position: LatLng(
                        widget.currentLocation!.latitude,
                        widget.currentLocation!.longitude,
                      ),
                      infoWindow: const InfoWindow(
                        title: 'Session Location',
                        snippet: 'Students must be within 500m radius',
                      ),
                    ),
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ],

          // Location Requirements
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Location Requirements",
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  "• GPS accuracy should be better than 20 meters\n• Students must be within 500m of this location\n• Location will be verified when students mark attendance",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
