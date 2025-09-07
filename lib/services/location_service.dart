import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location with high accuracy
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException('Location services are disabled. Please enable them to mark attendance.');
      }

      // Check and request permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw LocationServiceException('Location permissions are denied. Please grant location permission to mark attendance.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationServiceException('Location permissions are permanently denied. Please enable them in device settings.');
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      if (e is LocationServiceException) {
        rethrow;
      }
      throw LocationServiceException('Failed to get location: $e');
    }
  }

  /// Calculate distance between two coordinates in meters
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if a position is within a certain radius of another position
  bool isWithinRadius(Position position1, Position position2, double radiusInMeters) {
    double distance = calculateDistance(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
    return distance <= radiusInMeters;
  }

  /// Get location permission status for UI display
  Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.disabled;
    }

    LocationPermission permission = await checkLocationPermission();
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unknown;
    }
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for permission management
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get location accuracy description
  String getLocationAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (1000m)';
      case LocationAccuracy.low:
        return 'Low (500m)';
      case LocationAccuracy.medium:
        return 'Medium (100m)';
      case LocationAccuracy.high:
        return 'High (10m)';
      case LocationAccuracy.reduced:
        return 'Reduced (500m)';
      case LocationAccuracy.best:
        return 'Best (1m)';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation (1m)';
    }
  }

  /// Validate location data for attendance
  Future<LocationValidationResult> validateLocationForAttendance(
    Position currentPosition,
    Position sessionPosition,
    double allowedRadius,
  ) async {
    try {
      // Check if location is within allowed radius
      bool isWithinRadius = this.isWithinRadius(
        currentPosition,
        sessionPosition,
        allowedRadius,
      );

      // Check location accuracy (should be within 50 meters for reliable attendance)
      bool isAccurateEnough = currentPosition.accuracy <= 50.0;

      return LocationValidationResult(
        isValid: isWithinRadius && isAccurateEnough,
        isWithinRadius: isWithinRadius,
        isAccurateEnough: isAccurateEnough,
        distance: calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          sessionPosition.latitude,
          sessionPosition.longitude,
        ),
        accuracy: currentPosition.accuracy,
        message: _getValidationMessage(isWithinRadius, isAccurateEnough),
      );
    } catch (e) {
      return LocationValidationResult(
        isValid: false,
        isWithinRadius: false,
        isAccurateEnough: false,
        distance: 0,
        accuracy: 0,
        message: 'Location validation failed: $e',
      );
    }
  }

  String _getValidationMessage(bool isWithinRadius, bool isAccurateEnough) {
    if (!isWithinRadius && !isAccurateEnough) {
      return 'You are too far from the session location and location accuracy is insufficient.';
    } else if (!isWithinRadius) {
      return 'You are too far from the session location.';
    } else if (!isAccurateEnough) {
      return 'Location accuracy is insufficient. Please wait for better GPS signal.';
    } else {
      return 'Location verified successfully.';
    }
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

enum LocationPermissionStatus {
  disabled,
  denied,
  deniedForever,
  granted,
  unknown,
}

class LocationValidationResult {
  final bool isValid;
  final bool isWithinRadius;
  final bool isAccurateEnough;
  final double distance;
  final double accuracy;
  final String message;

  LocationValidationResult({
    required this.isValid,
    required this.isWithinRadius,
    required this.isAccurateEnough,
    required this.distance,
    required this.accuracy,
    required this.message,
  });
}
