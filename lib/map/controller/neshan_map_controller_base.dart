import 'dart:async';
import 'package:latlong2/latlong.dart';

import '../models/neshan_marker.dart';
import '../../utils/neshan_map_logger.dart';

/// Internal implementation interface for the map controller.
///
/// This is implemented differently for mobile (WebView) and web (iframe).
abstract class NeshanMapControllerImpl {
  Completer<void>? _readyCompleter;
  Timer? _readyTimeout;

  /// Logger for debug output.
  NeshanMapLogger logger = NeshanMapLogger.disabled;

  /// Sets the logger for this controller implementation.
  void setLogger(NeshanMapLogger newLogger) {
    logger = newLogger;
  }

  /// Future that completes when the controller is ready to receive commands.
  ///
  /// This will complete when the WebViewController (mobile) or iframe (web)
  /// is registered and ready. If the controller doesn't become ready within
  /// 10 seconds, the future will complete with a timeout error.
  Future<void> get ready {
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      return _readyCompleter!.future;
    }
    _readyCompleter = Completer<void>();
    _readyTimeout?.cancel();
    _readyTimeout = Timer(const Duration(seconds: 10), () {
      if (!_readyCompleter!.isCompleted) {
        _readyCompleter!.completeError(
          TimeoutException('Controller did not become ready within 10 seconds'),
        );
      }
    });
    return _readyCompleter!.future;
  }

  /// Marks the controller as ready.
  ///
  /// This should be called when the WebViewController (mobile) or iframe (web)
  /// is registered and ready to receive commands.
  void markReady() {
    _readyTimeout?.cancel();
    _readyTimeout = null;
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.complete();
    }
  }

  void moveToLocation(double lat, double lng, {double? zoom});
  void setZoom(double zoom);
  Future<LatLng?> getCurrentLocation();
  Future<double?> getCurrentZoom();
  void fitBounds(double north, double south, double east, double west);

  /// Adds a single marker to the map.
  void addMarker(NeshanMarker marker);

  /// Removes a marker by its ID.
  void removeMarker(String markerId);

  /// Updates all markers on the map (replaces existing markers).
  void updateMarkers(List<NeshanMarker> markers);

  /// Clears all markers from the map.
  void clearMarkers();

  /// Sets the WebViewController (mobile only).
  ///
  /// No-op by default, implemented in mobile implementation.
  void setWebViewController(dynamic controller) {
    // No-op by default
  }

  /// Sets the iframe element (web only).
  ///
  /// No-op by default, implemented in web implementation.
  void setIframe(dynamic iframe) {
    // No-op by default
  }

  /// Disposes of the controller and cleans up resources.
  ///
  /// Call this when the controller is no longer needed to prevent memory leaks.
  /// This cancels any pending timeout timers.
  void dispose() {
    _readyTimeout?.cancel();
    _readyTimeout = null;
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.completeError(
        Exception('Controller disposed before becoming ready'),
      );
    }
  }
}
