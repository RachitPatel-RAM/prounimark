import 'package:geolocator/geolocator.dart';

class LocationValidationService {
  static final LocationValidationService _instance = LocationValidationService._internal();
  factory LocationValidationService() => _instance;
  LocationValidationService._internal();

  /// Check if location services are enabled and permissions are granted
  Future<LocationValidationResult> validateLocationAccess() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationValidationResult.failure(
          'Location services are disabled. Please enable location services to use this application.',
          LocationValidationError.locationDisabled
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationValidationResult.failure(
            'Location permission is required to use this application. Please grant location permission.',
            LocationValidationError.permissionDenied
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationValidationResult.failure(
          'Location permission is permanently denied. Please enable location permission in device settings to use this application.',
          LocationValidationError.permissionDeniedForever
        );
      }

      // Test location accuracy
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        if (position.accuracy > 100) {
          return LocationValidationResult.failure(
            'Location accuracy is too low. Please move to an area with better GPS signal.',
            LocationValidationError.lowAccuracy
          );
        }

        return LocationValidationResult.success();
      } catch (e) {
        return LocationValidationResult.failure(
          'Failed to get current location. Please ensure GPS is enabled and try again.',
          LocationValidationError.locationUnavailable
        );
      }

    } catch (e) {
      return LocationValidationResult.failure(
        'Location validation failed: $e',
        LocationValidationError.unknown
      );
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

  /// Open app settings for permission management
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get current location permission status
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
}

/// Location validation result
class LocationValidationResult {
  final bool isSuccess;
  final String? errorMessage;
  final LocationValidationError? errorType;

  LocationValidationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.errorType,
  });

  factory LocationValidationResult.success() {
    return LocationValidationResult._(isSuccess: true);
  }

  factory LocationValidationResult.failure(String message, LocationValidationError errorType) {
    return LocationValidationResult._(
      isSuccess: false,
      errorMessage: message,
      errorType: errorType,
    );
  }
}

/// Location validation error types
enum LocationValidationError {
  locationDisabled,
  permissionDenied,
  permissionDeniedForever,
  lowAccuracy,
  locationUnavailable,
  unknown,
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
