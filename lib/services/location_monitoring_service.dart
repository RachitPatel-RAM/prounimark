import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationMonitoringService {
  static final LocationMonitoringService _instance = LocationMonitoringService._internal();
  factory LocationMonitoringService() => _instance;
  LocationMonitoringService._internal();

  Timer? _locationTimer;
  bool _isLocationEnabled = false;
  final List<VoidCallback> _locationListeners = [];

  bool get isLocationEnabled => _isLocationEnabled;

  void addLocationListener(VoidCallback listener) {
    _locationListeners.add(listener);
  }

  void removeLocationListener(VoidCallback listener) {
    _locationListeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _locationListeners) {
      listener();
    }
  }

  Future<void> startMonitoring() async {
    // Check initial status
    await _checkLocationStatus();

    // Start periodic monitoring
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkLocationStatus();
    });
  }

  void stopMonitoring() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _checkLocationStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      
      bool wasEnabled = _isLocationEnabled;
      _isLocationEnabled = serviceEnabled && 
          (permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always);

      // Notify listeners if status changed
      if (wasEnabled != _isLocationEnabled) {
        _notifyListeners();
      }
    } catch (e) {
      // Handle error silently
      bool wasEnabled = _isLocationEnabled;
      _isLocationEnabled = false;
      
      if (wasEnabled != _isLocationEnabled) {
        _notifyListeners();
      }
    }
  }

  Future<bool> requestLocationAccess() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      await _checkLocationStatus();
      return _isLocationEnabled;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    stopMonitoring();
    _locationListeners.clear();
  }
}
