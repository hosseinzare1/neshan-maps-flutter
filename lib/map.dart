/// Map module for the neshan_maps_flutter package.
///
/// This module provides core map functionality including:
/// - Map display widget ([NeshanMap])
/// - Map configuration ([NeshanMapConfig])
/// - Map controller ([NeshanMapController])
/// - Map markers ([NeshanMarker])
/// - Error callbacks (`onError`, `onLocationError`) on [NeshanMap]
///
/// ## Usage
///
/// ```dart
/// import 'package:neshan_maps_flutter/map.dart';
/// import 'package:latlong2/latlong.dart';
///
/// NeshanMap(
///   mapKey: 'your-api-key',
///   config: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///   ),
/// );
/// ```
library;

// Core map exports
export 'src/map/neshan_map.dart';
export 'src/map/config/neshan_map_config.dart';
export 'src/map/controller/neshan_map_controller.dart';
export 'src/map/models/neshan_marker.dart';
export 'src/utils/neshan_common.dart';
