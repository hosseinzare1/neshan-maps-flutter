import 'package:latlong2/latlong.dart';

import '../models/neshan_marker.dart';

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

/// Configuration for initializing a Neshan map.
///
/// This class allows you to configure the initial state and behavior of the map.
/// All parameters are optional and will use sensible defaults if not provided.
///
/// ## Usage Example
///
/// ```dart
/// final config = NeshanMapConfig(
///   initialCenter: LatLng(35.6892, 51.3890), // Tehran, Iran
///   initialZoom: 15.0,
///   mapType: NeshanMapType.neshanVector,
///   minZoom: 5.0,
///   maxZoom: 18.0,
///   showPoi: true,
///   showTraffic: false,
/// );
///
/// NeshanMap(
///   mapKey: 'your-api-key',
///   config: config,
/// )
/// ```
///
/// ## Default Values
///
/// - **initialCenter**: `LatLng(35.6892, 51.3890)` (Tehran, Iran)
/// - **initialZoom**: `12.0`
/// - **mapType**: `NeshanMapType.neshanVector`
/// - **minZoom**: `2.0`
/// - **maxZoom**: `21.0`
/// - **showPoi**: `true`
/// - **showTraffic**: `false`
///
/// ## Map Types
///
/// Available map types via [NeshanMapType] enum:
/// - `NeshanMapType.neshanVector` - Neshan vector map (default)
/// - `NeshanMapType.neshanVectorNight` - Neshan vector map (night mode)
/// - `NeshanMapType.neshanRaster` - Neshan raster map
/// - `NeshanMapType.neshanRasterNight` - Neshan raster map (night mode)
class NeshanMapConfig {
  /// Creates a map configuration with the specified parameters.
  ///
  /// [initialCenter] - The initial center of the map (default: Tehran, Iran).
  /// [initialZoom] - The initial zoom level (default: 12).
  /// [mapType] - The type of map to display (default: NeshanMapType.neshanVector).
  /// [minZoom] - The minimum zoom level (default: 2).
  /// [maxZoom] - The maximum zoom level (default: 21).
  /// [showPoi] - Whether to show points of interest (default: true).
  /// [showTraffic] - Whether to show traffic information (default: false).
  /// [markers] - List of markers to display on the map (default: empty list).
  /// [showCurrentLocationButton] - Whether to show the current location button (default: true).
  const NeshanMapConfig({
    this.initialCenter = const LatLng(35.6892, 51.3890), // Tehran, Iran
    this.initialZoom = 12.0,
    this.mapType = NeshanMapType.neshanVector,
    this.minZoom = 2.0,
    this.maxZoom = 21.0,
    this.showPoi = true,
    this.showTraffic = false,
    this.markers = const [],
    this.showCurrentLocationButton = true,
  });

  /// The initial center of the map.
  final LatLng initialCenter;

  /// The initial zoom level.
  final double initialZoom;

  /// The type of map to display.
  ///
  /// See [NeshanMapType] for available options.
  final NeshanMapType mapType;

  /// The minimum zoom level.
  final double minZoom;

  /// The maximum zoom level.
  final double maxZoom;

  /// Whether to show points of interest.
  final bool showPoi;

  /// Whether to show traffic information.
  final bool showTraffic;

  /// List of markers to display on the map.
  final List<NeshanMarker> markers;

  /// Whether to show the current location button.
  ///
  /// When enabled, a floating action button is displayed in the bottom-right
  /// corner of the map that allows users to center the map on their current location.
  ///
  /// The button will:
  /// - Request location permissions if not granted
  /// - Request location services if disabled
  /// - Track user location continuously
  /// - Move map to location on first tap, then just update marker position
  final bool showCurrentLocationButton;
}
