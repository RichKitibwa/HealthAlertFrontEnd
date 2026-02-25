// Location utilities
// GPS location capture and management with proper permission handling

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Error codes for location failures. Use with [LocationUtils.localizedErrorMessage]
/// to show a localized message in the UI.
class LocationErrorCode {
  LocationErrorCode._();
  static const String locationServicesDisabled = 'location_services_disabled';
  static const String locationPermissionDenied = 'location_permission_denied';
  static const String locationPermissionDeniedForever = 'location_permission_denied_forever';
  static const String locationTimeout = 'location_timeout';
  static const String locationUnknown = 'location_unknown';
}

/// Result object for location requests that includes error context
class LocationResult {
  final Position? position;
  final String? error;
  /// Optional code for UI to map to localized message via [LocationUtils.localizedErrorMessage].
  final String? errorCode;
  final bool permissionDeniedForever;

  LocationResult({
    this.position,
    this.error,
    this.errorCode,
    this.permissionDeniedForever = false,
  });

  bool get success => position != null;
}

class LocationUtils {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Request location permission using permission_handler (more reliable)
  /// Returns true if granted.
  static Future<bool> requestLocationPermission() async {
    // First check current status
    var status = await Permission.locationWhenInUse.status;

    if (status.isGranted) return true;

    // Request permission
    status = await Permission.locationWhenInUse.request();

    return status.isGranted;
  }

  /// Get current location with detailed error reporting.
  /// Returns a LocationResult with either a position or an error message.
  static Future<LocationResult> getCurrentLocationWithDetails() async {
    try {
      // Step 1: Check if location services (GPS) are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          error: 'Location services are disabled. Please enable GPS in your device settings.',
          errorCode: LocationErrorCode.locationServicesDisabled,
        );
      }

      // Step 2: Request permission using permission_handler
      var permStatus = await Permission.locationWhenInUse.status;

      if (permStatus.isDenied) {
        permStatus = await Permission.locationWhenInUse.request();
      }

      if (permStatus.isDenied) {
        return LocationResult(
          error: 'Location permission was denied. Please grant location access to report emergencies.',
          errorCode: LocationErrorCode.locationPermissionDenied,
        );
      }

      if (permStatus.isPermanentlyDenied) {
        return LocationResult(
          error: 'Location permission is permanently denied. Please open Settings and enable location for this app.',
          errorCode: LocationErrorCode.locationPermissionDeniedForever,
          permissionDeniedForever: true,
        );
      }

      // Step 3: Get the position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Location request timed out'),
      );

      return LocationResult(position: position);
    } catch (e) {
      final isTimeout = e is TimeoutException || e.toString().toLowerCase().contains('timed out');
      return LocationResult(
        error: 'Could not get location: ${e.toString()}',
        errorCode: isTimeout ? LocationErrorCode.locationTimeout : LocationErrorCode.locationUnknown,
      );
    }
  }

  // Get current location (legacy - returns null on failure)
  static Future<Position?> getCurrentLocation() async {
    final result = await getCurrentLocationWithDetails();
    return result.position;
  }

  // Get last known location
  static Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two coordinates (in meters)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Open device location settings
  static Future<bool> openLocationSettings() async {
    return await openAppSettings();
  }
}
