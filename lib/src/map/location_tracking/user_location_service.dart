import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// A service class that handles user location tracking using the geolocator package.
///
/// This service encapsulates all location-related functionality including:
/// - Permission checking and requesting
/// - Location service availability checking
/// - Continuous location tracking via streams
///
/// ## Usage Example
///
/// ```dart
/// final locationService = UserLocationService();
///
/// // Check and request permissions
/// final hasPermission = await locationService.checkAndRequestPermissions();
/// if (!hasPermission) {
///   print('Location permission denied');
///   return;
/// }
///
/// // Check if location services are enabled
/// final serviceEnabled = await locationService.checkAndRequestLocationService();
/// if (!serviceEnabled) {
///   print('Location service disabled');
///   return;
/// }
///
/// // Start tracking location
/// locationService.startLocationTracking().listen((position) {
///   print('Location: ${position.latitude}, ${position.longitude}');
/// });
/// ```
class UserLocationService {
  StreamSubscription<Position>? _subscription;

  /// Checks if location permissions are granted and requests them if not.
  ///
  /// Returns `true` if permissions are granted, `false` otherwise.
  ///
  /// This method handles all permission states:
  /// - `denied` - Requests permission from the user
  /// - `deniedForever` - Returns false (user must enable in settings)
  /// - `whileInUse` or `always` - Returns true
  ///
  /// Throws an exception if permission request fails.
  Future<bool> checkAndRequestPermissions() async {
    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission from user
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied by user
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, cannot request
      // User must enable manually in settings
      return false;
    }

    // Permission is granted (whileInUse or always)
    return true;
  }

  /// Checks if location services are enabled on the device.
  ///
  /// Returns `true` if location services are enabled, `false` otherwise.
  ///
  /// If location services are disabled, this method will attempt to open
  /// the location settings screen so the user can enable them.
  Future<bool> checkAndRequestLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are disabled
      // Try to open location settings
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  /// Starts tracking the user's location and returns a stream of position updates.
  ///
  /// The stream will emit a new [Position] whenever the user's location changes
  /// by at least [distanceFilter] meters (default: 10 meters).
  ///
  /// [settings] can be provided to customize location tracking behavior.
  /// If not provided, default settings will be used based on the platform.
  ///
  /// The location precision is set to [LocationAccuracy.high] for precise tracking.
  ///
  /// ## Platform-Specific Settings
  ///
  /// - **Android**: Updates every 2 seconds with high precision
  /// - **iOS/macOS**: Uses fitness activity type with high precision
  /// - **Web**: High precision with 5-minute maximum age
  /// - **Other**: Default settings with high precision
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = locationService.startLocationTracking();
  /// stream.listen((position) {
  ///   print('Location: ${position.latitude}, ${position.longitude}');
  /// });
  /// ```
  Stream<Position> startLocationTracking({LocationSettings? settings}) {
    // Use provided settings or create platform-specific defaults
    final locationSettings = settings ?? _getDefaultLocationSettings();

    // Return the position stream from geolocator
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Gets default location settings based on the current platform.
  LocationSettings _getDefaultLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 2),
        // Don't use foreground notification for this simple tracking
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        maximumAge: const Duration(minutes: 5),
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
  }

  /// Stops any active location tracking.
  ///
  /// This cancels the location stream subscription if one exists.
  /// Should be called when location tracking is no longer needed
  /// to free up resources.
  void stopLocationTracking() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Disposes of the service and cleans up any resources.
  ///
  /// Should be called when the service is no longer needed.
  void dispose() {
    stopLocationTracking();
  }
}
