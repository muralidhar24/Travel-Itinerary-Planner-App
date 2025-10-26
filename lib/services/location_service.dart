import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  static LocationService get instance => _instance;

  LocationService._internal();

  Position? _currentPosition;
  bool _locationEnabled = false;
  bool _permissionGranted = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  bool get locationEnabled => _locationEnabled;
  bool get permissionGranted => _permissionGranted;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _loadSettings();
    if (_locationEnabled) {
      await checkPermission();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locationEnabled = prefs.getBool('location_enabled') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location settings: $e');
    }
  }

  Future<void> setLocationEnabled(bool enabled) async {
    _locationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', enabled);
    
    if (enabled) {
      await checkPermission();
    }
    
    notifyListeners();
  }

  Future<bool> checkPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please enable them in settings.';
        _permissionGranted = false;
        notifyListeners();
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied.';
          _permissionGranted = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.';
        _permissionGranted = false;
        notifyListeners();
        return false;
      }

      _permissionGranted = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error checking location permission: $e';
      _permissionGranted = false;
      notifyListeners();
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (!_locationEnabled) {
      _errorMessage = 'Location services are disabled.';
      notifyListeners();
      return null;
    }

    if (!_permissionGranted) {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _errorMessage = null;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _errorMessage = 'Error getting current location: $e';
      notifyListeners();
      return null;
    }
  }

  Future<double> getDistanceToDestination(double destLat, double destLng) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }

    if (_currentPosition == null) {
      return 0.0;
    }

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      destLat,
      destLng,
    ) / 1000; // Convert to kilometers
  }

  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}