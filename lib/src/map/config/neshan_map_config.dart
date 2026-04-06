import 'package:latlong2/latlong.dart';

/// Enum representing the different types of Neshan maps available.
enum NeshanMapType {
  /// Neshan vector map (default)
  neshanVector,

  /// Neshan vector map (night mode)
  neshanVectorNight,

  /// Neshan raster map
  neshanRaster,

  /// Neshan raster map (night mode)
  neshanRasterNight;

  /// Returns the string value used by the Neshan SDK.
  String get value {
    switch (this) {
      case NeshanMapType.neshanVector:
        return 'neshanVector';
      case NeshanMapType.neshanVectorNight:
        return 'neshanVectorNight';
      case NeshanMapType.neshanRaster:
        return 'neshanRaster';
      case NeshanMapType.neshanRasterNight:
        return 'neshanRasterNight';
    }
  }
}

/// Viewport and style configuration for initializing a [NeshanMap].
///
/// This class holds **static initial-state** values that describe how the map
/// is rendered at startup: the viewport position, zoom bounds, map style, and
/// overlay toggles. It is intentionally scoped to these concerns.
///
/// **Markers are not part of this config.** Pass them directly to the
/// [NeshanMap.markers] parameter so they live alongside the controller and
/// other widget-level data, keeping this class focused solely on viewport
/// configuration.
///
/// All parameters are optional and fall back to sensible defaults.
///
/// ## Usage Example
///
/// ```dart
/// NeshanMap(
///   mapKey: 'your-api-key',
///   config: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890), // Tehran, Iran
///     initialZoom: 15.0,
///     mapType: NeshanMapType.neshanVector,
///     showTraffic: true,
///   ),
///   markers: [
///     NeshanMarker(
///       id: 'hq',
///       position: LatLng(35.6892, 51.3890),
///       title: 'HQ',
///     ),
///   ],
/// )
/// ```
///
/// ## Default Values
///
/// | Parameter | Default |
/// |---|---|
/// | [initialCenter] | `LatLng(35.6892, 51.3890)` (Tehran) |
/// | [initialZoom] | `12.0` |
/// | [mapType] | [NeshanMapType.neshanVector] |
/// | [minZoom] | `2.0` |
/// | [maxZoom] | `21.0` |
/// | [showPoi] | `true` |
/// | [showTraffic] | `false` |
/// | [showCurrentLocationButton] | `true` |
///
/// ## Map Types
///
/// Available map types via [NeshanMapType]:
/// - [NeshanMapType.neshanVector] — default vector map
/// - [NeshanMapType.neshanVectorNight] — vector map, night mode
/// - [NeshanMapType.neshanRaster] — raster map
/// - [NeshanMapType.neshanRasterNight] — raster map, night mode
class NeshanMapConfig {
  /// Creates a viewport/style configuration for a [NeshanMap].
  ///
  /// [initialCenter] — Initial center coordinate (default: Tehran, Iran).
  /// [initialZoom] — Initial zoom level (default: `12.0`).
  /// [mapType] — Map style to display (default: [NeshanMapType.neshanVector]).
  /// [minZoom] — Minimum allowed zoom level (default: `2.0`).
  /// [maxZoom] — Maximum allowed zoom level (default: `21.0`).
  /// [showPoi] — Whether to render points of interest (default: `true`).
  /// [showTraffic] — Whether to render the traffic layer (default: `false`).
  /// [showCurrentLocationButton] — Whether to show the current-location FAB
  /// (default: `true`).
  const NeshanMapConfig({
    this.initialCenter = const LatLng(35.6892, 51.3890),
    this.initialZoom = 12.0,
    this.mapType = NeshanMapType.neshanVector,
    this.minZoom = 2.0,
    this.maxZoom = 21.0,
    this.showPoi = true,
    this.showTraffic = false,
    this.showCurrentLocationButton = true,
  });

  /// The initial center coordinate of the map.
  ///
  /// Defaults to Tehran, Iran (`LatLng(35.6892, 51.3890)`).
  final LatLng initialCenter;

  /// The initial zoom level.
  ///
  /// Must be between [minZoom] and [maxZoom]. Defaults to `12.0`.
  final double initialZoom;

  /// The map style to display.
  ///
  /// See [NeshanMapType] for available options. Defaults to
  /// [NeshanMapType.neshanVector].
  final NeshanMapType mapType;

  /// The minimum zoom level the user can zoom out to.
  ///
  /// Defaults to `2.0`.
  final double minZoom;

  /// The maximum zoom level the user can zoom in to.
  ///
  /// Defaults to `21.0`.
  final double maxZoom;

  /// Whether to render points of interest on the map.
  ///
  /// Defaults to `true`.
  final bool showPoi;

  /// Whether to render the traffic layer on the map.
  ///
  /// Defaults to `false`.
  final bool showTraffic;

  /// Whether to show the current-location floating action button.
  ///
  /// When `true`, a FAB is shown in the bottom-right corner. Tapping it:
  /// - Requests location permission if not already granted.
  /// - Opens location-service settings if the service is disabled.
  /// - Starts continuous location tracking.
  /// - On the first update, flies the map to the user's position; subsequent
  ///   updates only move the location dot without re-centering the map.
  ///
  /// Defaults to `true`.
  final bool showCurrentLocationButton;
}
