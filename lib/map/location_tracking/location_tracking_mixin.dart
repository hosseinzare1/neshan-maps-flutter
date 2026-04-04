import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/neshan_map_logger.dart';
import '../../utils/neshan_common.dart';
import 'user_location_service.dart';

/// Mixin that provides location tracking functionality for map widgets.
///
/// This mixin encapsulates all location tracking logic including:
/// - Permission and service checks
/// - Location subscription management
/// - User location updates
/// - Error handling
///
/// Platform-specific implementations must provide:
/// - [sendUserLocationToMap] - Send location to the map view
/// - [resetUserLocationFirstUpdate] - Reset first update flag
/// - [logger] - Logger instance
/// - [onLocationError] - Error callback
mixin LocationTrackingMixin<T extends StatefulWidget> on State<T> {
  final _locationService = UserLocationService();
  StreamSubscription<Position>? _locationSubscription;
  bool _isTrackingLocation = false;

  /// Whether location tracking is currently active.
  bool get isTrackingLocation => _isTrackingLocation;

  /// Logger instance for debug output.
  /// Must be implemented by the platform-specific state.
  NeshanMapLogger get logger;

  /// Error callback for location errors.
  /// Must be implemented by the platform-specific state.
  NeshanErrorCallback? get onLocationError;

  /// Send user location to the map view.
  /// Platform-specific implementation required.
  void sendUserLocationToMap(double lat, double lng);

  /// Reset the user location first update flag.
  /// Platform-specific implementation required.
  void resetUserLocationFirstUpdate();

  /// Handle current location button tap.
  ///
  /// This method:
  /// 1. Checks and requests location permissions
  /// 2. Checks and requests location service
  /// 3. Starts location tracking
  /// 4. Handles errors via [onLocationError] callback
  Future<void> handleCurrentLocationTap() async {
    logger.log('Current location button tapped');
    // If already tracking, stop and restart (to re-center map)
    if (_isTrackingLocation) {
      logger.log('Restarting location tracking');
      _locationSubscription?.cancel();
      if (mounted) {
        setState(() => _isTrackingLocation = false);
      }
      // Reset first update flag
      resetUserLocationFirstUpdate();
    }

    // Permission check
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) {
      logger.error('Location permission denied', null);
      onLocationError?.call('Location permission denied', null, null);
      return;
    }

    // Service check
    final serviceEnabled = await _locationService
        .checkAndRequestLocationService();
    if (!serviceEnabled) {
      logger.error('Location service disabled', null);
      onLocationError?.call('Location service disabled', null, null);
      return;
    }

    // Start tracking
    logger.log('Starting location tracking');
    if (mounted) {
      setState(() => _isTrackingLocation = true);
    }
    // Reset first update flag so map moves on next location
    resetUserLocationFirstUpdate();

    _locationSubscription = _locationService.startLocationTracking().listen(
      (position) {
        sendUserLocationToMap(position.latitude, position.longitude);
      },
      onError: (error, stackTrace) {
        logger.error('Location tracking error', error);
        onLocationError?.call(
          'Location error',
          error is Exception ? error : Exception(error.toString()),
          stackTrace,
        );
        if (mounted) {
          setState(() => _isTrackingLocation = false);
        }
      },
    );
  }

  /// Dispose location tracking resources.
  ///
  /// This should be called from the platform-specific state's dispose method.
  void disposeLocationTracking() {
    _locationSubscription?.cancel();
    _locationService.dispose();
  }
}
