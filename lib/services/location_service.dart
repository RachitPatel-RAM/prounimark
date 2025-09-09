import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_service.g.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Constants
  static const double _minimumAccuracy = 50.0; // meters
  static const int _locationTimeoutSeconds = 10;

  /// Check and request location permissions
  Future<LocationPermissionResult> checkAndRequestPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult.failure(
          'Location services are disabled. Please enable location services in device settings.'
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.failure(
            'Location permissions are denied. Please grant location permission to mark attendance.'
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult.failure(
          'Location permissions are permanently denied. Please enable location permissions in device settings.'
        );
      }

      return LocationPermissionResult.success();
    } catch (e) {
      return LocationPermissionResult.failure('Permission check failed: $e');
    }
  }

  /// Get current location with high accuracy
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check permissions first
      final permissionResult = await checkAndRequestPermissions();
      if (!permissionResult.isSuccess) {
        return LocationResult.failure(permissionResult.error!);
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: _locationTimeoutSeconds),
        ),
      );

      // Check accuracy
      if (position.accuracy > _minimumAccuracy) {
        return LocationResult.failure(
          'Location accuracy is too low (${position.accuracy.toStringAsFixed(0)}m). Please move to an area with better GPS signal.'
        );
      }

      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      return LocationResult.success(location);
    } catch (e) {
      return LocationResult.failure('Failed to get location: $e');
    }
  }

  /// Check if location is within session radius
  bool isWithinRadius(
    LocationData userLocation,
    LocationData sessionLocation,
    double radiusMeters,
  ) {
    final distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      sessionLocation.latitude,
      sessionLocation.longitude,
    );

    return distance <= radiusMeters;
  }

  /// Calculate distance between two points using Haversine formula
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = lat1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLatRad = (lat2 - lat1) * (pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Verify location for attendance submission
  Future<LocationVerificationResult> verifyLocationForAttendance(
    LocationData sessionLocation,
    double sessionRadius,
  ) async {
    try {
      // Get current location
      final locationResult = await getCurrentLocation();
      if (!locationResult.isSuccess) {
        return LocationVerificationResult.failure(locationResult.error!);
      }

      final userLocation = locationResult.location!;

      // Check if within radius
      final isWithinRadius = this.isWithinRadius(
        userLocation,
        sessionLocation,
        sessionRadius,
      );

      if (!isWithinRadius) {
        final distance = calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          sessionLocation.latitude,
          sessionLocation.longitude,
        );

        return LocationVerificationResult.failure(
          'You are ${distance.toStringAsFixed(0)}m away from the session location. Please move within ${sessionRadius.toStringAsFixed(0)}m to mark attendance.'
        );
      }

      return LocationVerificationResult.success(userLocation);
    } catch (e) {
      return LocationVerificationResult.failure('Location verification failed: $e');
    }
  }

  /// Get location permission status
  Future<LocationPermissionStatus> getPermissionStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.disabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.whileInUse;
        case LocationPermission.always:
          return LocationPermissionStatus.always;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unableToDetermine;
      }
    } catch (e) {
      return LocationPermissionStatus.error;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get formatted distance string
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  /// Get location accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 10) {
      return 'Excellent';
    } else if (accuracy <= 20) {
      return 'Good';
    } else if (accuracy <= 50) {
      return 'Fair';
    } else if (accuracy <= 100) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }
}

/// Location data class
@JsonSerializable()
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }

  factory LocationData.fromFirestore(Map<String, dynamic> data) {
    return LocationData(
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
    );
  }
}

/// Location permission result
class LocationPermissionResult {
  final bool isSuccess;
  final String? error;

  LocationPermissionResult._({
    required this.isSuccess,
    this.error,
  });

  factory LocationPermissionResult.success() {
    return LocationPermissionResult._(isSuccess: true);
  }

  factory LocationPermissionResult.failure(String error) {
    return LocationPermissionResult._(isSuccess: false, error: error);
  }
}

/// Location result
class LocationResult {
  final bool isSuccess;
  final String? error;
  final LocationData? location;

  LocationResult._({
    required this.isSuccess,
    this.error,
    this.location,
  });

  factory LocationResult.success(LocationData location) {
    return LocationResult._(isSuccess: true, location: location);
  }

  factory LocationResult.failure(String error) {
    return LocationResult._(isSuccess: false, error: error);
  }
}

/// Location verification result
class LocationVerificationResult {
  final bool isSuccess;
  final String? error;
  final LocationData? location;

  LocationVerificationResult._({
    required this.isSuccess,
    this.error,
    this.location,
  });

  factory LocationVerificationResult.success(LocationData location) {
    return LocationVerificationResult._(isSuccess: true, location: location);
  }

  factory LocationVerificationResult.failure(String error) {
    return LocationVerificationResult._(isSuccess: false, error: error);
  }
}

/// Location permission status
enum LocationPermissionStatus {
  disabled,
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
  error,
}