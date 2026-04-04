import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../utils/neshan_common.dart';
import 'controller/neshan_map_controller.dart';
import 'config/neshan_map_config.dart';
import '../utils/neshan_map_logger.dart';

// Platform-specific implementations with conditional imports
import 'platform/mobile/neshan_map_mobile_widget.dart'
    if (dart.library.js_interop) 'platform/neshan_map_stub.dart'
    as mobile_impl;
import 'platform/web/neshan_map_web_widget.dart'
    if (dart.library.io) 'platform/neshan_map_stub.dart'
    as web_impl;

/// A cross-platform widget that displays a Neshan map.
///
/// This widget provides a unified API for displaying Neshan maps across
/// different platforms:
/// - **Mobile (iOS/Android)**: Uses WebView to display the map
/// - **Web**: Uses an iframe to embed the HTML map
///
/// ## Features
///
/// - **Location Updates**: The map automatically sends location updates
///   when the center changes via the [onLocationChanged] callback.
/// - **Programmatic Control**: Use [NeshanMapController] to move the map,
///   change zoom, and perform other operations from Dart code.
/// - **Customizable Marker**: Display a custom marker at the center of the map,
///   or use the default location pin icon.
/// - **Error Handling**: Handle errors via the [onError] callback.
/// - **Configuration**: Customize initial map state via [NeshanMapConfig].
///
/// ## Usage Example
///
/// ```dart
/// final controller = NeshanMapController();
///
/// NeshanMap(
///   mapKey: 'your-neshan-api-key',
///   controller: controller,
///   config: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   onLocationChanged: (lat, lng) {
///     print('Map center: $lat, $lng');
///   },
///   onError: (message, description) {
///     print('Error: $message - $description');
///   },
/// )
///
/// // Later, move the map programmatically:
/// await controller.ready;
/// controller.moveToLocation(35.6892, 51.3890, zoom: 15);
/// ```
///
/// ## Platform-Specific Notes
///
/// - On mobile, the map is rendered in a WebView, which requires internet
///   connectivity to load the Neshan SDK.
/// - On web, the map is rendered in an iframe, which may have different
///   security restrictions depending on the browser.
/// - The [NeshanMapController.ready] future should be awaited before calling
///   controller methods to ensure the map is fully loaded.
class NeshanMap extends StatefulWidget {
  /// Creates a Neshan map widget.
  ///
  /// [mapKey] is the Neshan API key required to display the map.
  ///
  /// [controller] allows programmatic control of the map location.
  /// Use [NeshanMapController] to move the map to specific locations.
  ///
  /// [config] allows you to configure the initial map state and behavior.
  /// If not provided, default values will be used.
  ///
  /// [onLocationChanged] will be called whenever the map center changes.
  ///
  /// [onMarkerTapped] callback is called when a marker is tapped.
  /// Provides the ID of the tapped marker.
  ///
  /// [onError] callback is called when an error occurs (e.g., WebView errors,
  /// HTML loading errors, JSON parsing errors).
  ///
  /// [onLocationError] callback is called when location permission or service
  /// errors occur (e.g., permission denied, location service disabled).
  ///
  /// [enableDebug] enables detailed debug logging when set to `true`.
  const NeshanMap({
    super.key,
    required this.mapKey,
    this.controller,
    this.config,
    this.onLocationChanged,
    this.onMarkerTapped,
    this.onError,
    this.onLocationError,
    this.enableDebug = false,
  });

  /// The Neshan API key required to display the map.
  final String mapKey;

  /// Optional controller for programmatic map control.
  ///
  /// Use this to move the map to specific locations from Dart code.
  final NeshanMapController? controller;

  /// Optional configuration for the initial map state and behavior.
  ///
  /// If not provided, default values will be used (Tehran center, zoom 12, etc.).
  final NeshanMapConfig? config;

  /// Callback that is called when the map center changes.
  ///
  /// Provides the latitude and longitude of the map center.
  final void Function(double lat, double lng)? onLocationChanged;

  /// Callback that is called when a marker is tapped.
  ///
  /// Provides the ID of the tapped marker.
  final void Function(String markerId)? onMarkerTapped;

  /// Callback that is called when an error occurs.
  ///
  final NeshanErrorCallback? onError;

  /// Callback that is called when a location error occurs.
  ///
  /// This includes permission errors, location service errors, and tracking errors.
  final NeshanErrorCallback? onLocationError;

  /// Whether to enable debug logging for the map.
  ///
  /// When enabled, the map will print detailed debug information to the console,
  /// including initialization steps, location updates, marker operations, and errors.
  ///
  /// Defaults to `false`.
  final bool enableDebug;

  @override
  State<NeshanMap> createState() => _NeshanMapState();
}

class _NeshanMapState extends State<NeshanMap> {
  late final NeshanMapLogger _logger;

  @override
  void initState() {
    super.initState();
    _logger = NeshanMapLogger(enabled: widget.enableDebug, prefix: 'NeshanMap');
    _logger.log(
      'Initializing NeshanMap (platform: ${kIsWeb ? 'Web' : 'Mobile'})',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.NeshanMapWebWidget(
        mapKey: widget.mapKey,
        controller: widget.controller,
        config: widget.config,
        onLocationChanged: widget.onLocationChanged,
        onMarkerTapped: widget.onMarkerTapped,
        onError: widget.onError,
        onLocationError: widget.onLocationError,
        logger: _logger,
      );
    } else {
      return mobile_impl.NeshanMapMobileWidget(
        mapKey: widget.mapKey,
        controller: widget.controller,
        config: widget.config,
        onLocationChanged: widget.onLocationChanged,
        onMarkerTapped: widget.onMarkerTapped,
        onError: widget.onError,
        onLocationError: widget.onLocationError,
        logger: _logger,
      );
    }
  }
}
