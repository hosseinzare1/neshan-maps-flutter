import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../utils/neshan_common.dart';
import 'controller/neshan_map_controller.dart';
import 'config/neshan_map_config.dart';
import 'models/neshan_marker.dart';
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
/// Supports **iOS**, **Android**, and **Web**:
/// - **Mobile**: renders the map inside a [WebView].
/// - **Web**: renders the map inside an `<iframe>`.
///
/// ## Key Parameters
///
/// | Parameter | Purpose |
/// |---|---|
/// | [mapKey] | Neshan API key (required) |
/// | [config] | Viewport & style settings ([NeshanMapConfig]) |
/// | [markers] | Initial set of [NeshanMarker]s to show on the map |
/// | [controller] | [NeshanMapController] for programmatic control |
/// | [onLocationChanged] | Called when the map centre changes |
/// | [onMarkerTapped] | Called when a marker is tapped |
/// | [onError] | Called on general errors |
/// | [onLocationError] | Called on location-permission / service errors |
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:neshan_maps_flutter/map.dart';
/// import 'package:latlong2/latlong.dart';
///
/// NeshanMap(
///   mapKey: 'your-neshan-api-key',
///   config: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   onLocationChanged: (lat, lng) {
///     debugPrint('Centre: $lat, $lng');
///   },
/// )
/// ```
///
/// ## With Markers
///
/// Markers are passed directly to the widget, not via [NeshanMapConfig].
/// To add or remove markers after the map has loaded use [NeshanMapController]:
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:neshan_maps_flutter/map.dart';
/// import 'package:latlong2/latlong.dart';
///
/// final controller = NeshanMapController();
///
/// NeshanMap(
///   mapKey: 'your-neshan-api-key',
///   controller: controller,
///   markers: [
///     NeshanMarker(
///       id: 'hq',
///       position: LatLng(35.6892, 51.3890),
///       title: 'HQ',
///       color: Colors.red,
///     ),
///   ],
/// )
///
/// // Programmatically add another marker later:
/// await controller.ready;
/// controller.addMarker(
///   NeshanMarker(id: 'branch', position: LatLng(35.70, 51.40)),
/// );
/// ```
///
/// ## Platform Notes
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
  /// [mapKey] — The Neshan API key. Required.
  ///
  /// [config] — Viewport and style settings. Uses sensible defaults
  /// (Tehran centre, zoom 12, vector map) when omitted.
  ///
  /// [markers] — Initial list of [NeshanMarker]s placed on the map when it
  /// first loads. To mutate markers at runtime use [controller].
  ///
  /// [controller] — Optional [NeshanMapController] for programmatic control
  /// (move, zoom, add/remove markers, etc.).
  ///
  /// [onLocationChanged] — Fired whenever the map centre changes.
  ///
  /// [onMarkerTapped] — Fired when a marker is tapped; receives the marker ID.
  ///
  /// [onError] — Fired on WebView / iframe / parsing errors.
  ///
  /// [onLocationError] — Fired when location permission is denied or the
  /// location service is disabled.
  ///
  /// [enableDebug] — Enables verbose console logging. Defaults to `false`.
  const NeshanMap({
    super.key,
    required this.mapKey,
    this.config,
    this.markers = const [],
    this.controller,
    this.onLocationChanged,
    this.onMarkerTapped,
    this.onError,
    this.onLocationError,
    this.enableDebug = false,
  });

  /// The Neshan API key required to display the map.
  ///
  /// Obtain your key at https://platform.neshan.org/.
  final String mapKey;

  /// Viewport and style configuration for the map.
  ///
  /// Controls the initial centre, zoom, map type, traffic layer, POI rendering,
  /// and the current-location FAB. All fields have sensible defaults — you only
  /// need to provide values you want to override.
  ///
  /// If omitted, the map opens centred on Tehran at zoom 12.
  final NeshanMapConfig? config;

  /// Initial list of markers to display on the map.
  ///
  /// These markers are placed on the map when it first finishes loading.
  /// To add, remove, or replace markers after the map has loaded, use the
  /// methods on [controller] ([NeshanMapController.addMarker],
  /// [NeshanMapController.removeMarker], [NeshanMapController.updateMarkers],
  /// [NeshanMapController.clearMarkers]).
  ///
  /// Defaults to an empty list.
  final List<NeshanMarker> markers;

  /// Optional controller for programmatic map control.
  ///
  /// Provides methods to move the camera, change zoom, and manage markers
  /// at runtime. Await [NeshanMapController.ready] before calling any method
  /// to ensure the map is fully loaded.
  final NeshanMapController? controller;

  /// Called whenever the map centre changes (pan or programmatic move).
  ///
  /// Provides the new latitude and longitude of the map centre.
  final void Function(double lat, double lng)? onLocationChanged;

  /// Called when a marker on the map is tapped.
  ///
  /// Receives the [NeshanMarker.id] of the tapped marker.
  final void Function(String markerId)? onMarkerTapped;

  /// Called when a general error occurs (WebView error, iframe error, JSON
  /// parse failure, etc.).
  final NeshanErrorCallback? onError;

  /// Called when a location-related error occurs.
  ///
  /// Covers permission denied, location service disabled, and tracking errors.
  final NeshanErrorCallback? onLocationError;

  /// Enables verbose debug logging to the console.
  ///
  /// Logs include initialisation steps, location updates, marker operations,
  /// and errors. Defaults to `false`.
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
        markers: widget.markers,
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
        markers: widget.markers,
        onLocationChanged: widget.onLocationChanged,
        onMarkerTapped: widget.onMarkerTapped,
        onError: widget.onError,
        onLocationError: widget.onLocationError,
        logger: _logger,
      );
    }
  }
}
