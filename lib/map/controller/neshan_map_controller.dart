// Conditional imports
import 'package:latlong2/latlong.dart';

import 'neshan_map_controller_impl.dart'
    if (dart.library.js_interop) 'neshan_map_controller_stub.dart'
    as impl;

import 'neshan_map_controller_base.dart';
import '../models/neshan_marker.dart';
import '../../utils/neshan_map_logger.dart';

/// Controller for programmatically controlling the Neshan map.
///
/// This controller provides methods to interact with the map from Dart code,
/// such as moving to locations, changing zoom, getting current state, and
/// fitting bounds.
///
/// ## Usage
///
/// ```dart
/// final controller = NeshanMapController();
///
/// NeshanMap(
///   mapKey: 'your-api-key',
///   controller: controller,
///   // ... other params
/// )
///
/// // Wait for the controller to be ready before using it
/// await controller.ready;
///
/// // Move the map to a specific location
/// controller.moveToLocation(35.6892, 51.3890, zoom: 15);
///
/// // Get current location
/// final location = await controller.getCurrentLocation();
/// print('Current center: ${location?.latitude}, ${location?.longitude}');
///
/// // Get current zoom
/// final zoom = await controller.getCurrentZoom();
/// print('Current zoom: $zoom');
///
/// // Fit map to bounds
/// controller.fitBounds(36.0, 35.0, 52.0, 51.0);
/// ```
///
/// ## Important Notes
///
/// - Always await [ready] before calling controller methods to ensure the map
///   is fully loaded and ready to receive commands.
/// - The [ready] future will timeout after 10 seconds if the map doesn't
///   become ready.
/// - Methods that return values (like [getCurrentLocation] and [getCurrentZoom])
///   may return `null` if the map is not ready or an error occurs.
class NeshanMapController {
  /// Creates a new map controller.
  ///
  /// The [logger] parameter is optional and used for internal debugging.
  /// It is set by the NeshanMap widget when the controller is registered.
  NeshanMapController() : _impl = impl.createController();

  final NeshanMapControllerImpl _impl;

  /// Logger instance for debug logging.
  /// Set by NeshanMap when the controller is registered.
  NeshanMapLogger _logger = NeshanMapLogger.disabled;

  /// Internal method to set the logger.
  ///
  /// This is called automatically by the map implementation.
  void setLogger(NeshanMapLogger logger) {
    _logger = logger.withPrefix('Controller');
    _impl.setLogger(_logger);
  }

  /// Internal method to set the WebViewController (mobile only).
  ///
  /// This is called automatically by the mobile map implementation.
  void setWebViewController(dynamic controller) {
    _logger.log('Setting WebViewController, impl type: ${_impl.runtimeType}');
    _impl.setWebViewController(controller);
  }

  /// Internal method to set the iframe element (web only).
  ///
  /// This is called automatically by the web map implementation.
  void setIframe(dynamic iframe) {
    _logger.log('Setting iframe, impl type: ${_impl.runtimeType}');
    _impl.setIframe(iframe);
  }

  /// Moves the map to the specified location with optional zoom level.
  ///
  /// The map will animate smoothly to the new location using `flyTo`.
  ///
  /// [lat] and [lng] are the target latitude and longitude.
  /// [zoom] is optional - if not provided, the current zoom level is maintained.
  void moveToLocation(double lat, double lng, {double? zoom}) {
    _impl.moveToLocation(lat, lng, zoom: zoom);
  }

  /// Sets the zoom level of the map.
  ///
  /// The map will animate smoothly to the new zoom level.
  void setZoom(double zoom) {
    _impl.setZoom(zoom);
  }

  /// Future that completes when the controller is ready to receive commands.
  ///
  /// This will complete when the WebViewController (mobile) or iframe (web)
  /// is registered and ready. If the controller doesn't become ready within
  /// 10 seconds, the future will complete with a timeout error.
  ///
  /// Example:
  /// ```dart
  /// await controller.ready;
  /// controller.moveToLocation(35.6892, 51.3890);
  /// ```
  Future<void> get ready => _impl.ready;

  /// Gets the current center location of the map.
  ///
  /// Returns null if the map is not ready or an error occurs.
  Future<LatLng?> getCurrentLocation() {
    return _impl.getCurrentLocation();
  }

  /// Gets the current zoom level of the map.
  ///
  /// Returns null if the map is not ready or an error occurs.
  Future<double?> getCurrentZoom() {
    return _impl.getCurrentZoom();
  }

  /// Fits the map view to the specified bounds.
  ///
  /// [north], [south], [east], [west] define the bounding box in degrees.
  void fitBounds(double north, double south, double east, double west) {
    _impl.fitBounds(north, south, east, west);
  }

  /// Adds a single marker to the map.
  ///
  /// The marker will be added dynamically to the existing map.
  ///
  /// Example:
  /// ```dart
  /// final marker = NeshanMarker(
  ///   id: 'marker1',
  ///   position: LatLng(35.6892, 51.3890),
  ///   color: Colors.red,
  ///   title: 'Tehran',
  /// );
  /// controller.addMarker(marker);
  /// ```
  void addMarker(NeshanMarker marker) {
    _impl.addMarker(marker);
  }

  /// Removes a marker from the map by its ID.
  ///
  /// Example:
  /// ```dart
  /// controller.removeMarker('marker1');
  /// ```
  void removeMarker(String markerId) {
    _impl.removeMarker(markerId);
  }

  /// Updates all markers on the map.
  ///
  /// This replaces all existing markers with the new list.
  ///
  /// Example:
  /// ```dart
  /// final markers = [
  ///   NeshanMarker(id: 'marker1', position: LatLng(35.6892, 51.3890)),
  ///   NeshanMarker(id: 'marker2', position: LatLng(35.7, 51.4)),
  /// ];
  /// controller.updateMarkers(markers);
  /// ```
  void updateMarkers(List<NeshanMarker> markers) {
    _impl.updateMarkers(markers);
  }

  /// Clears all markers from the map.
  ///
  /// Example:
  /// ```dart
  /// controller.clearMarkers();
  /// ```
  void clearMarkers() {
    _impl.clearMarkers();
  }

  /// Disposes of the controller and cleans up resources.
  ///
  /// Call this when the controller is no longer needed to prevent memory leaks.
  /// This is particularly important if you create a controller but the widget
  /// is disposed before the map becomes ready.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   controller.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _impl.dispose();
  }
}
