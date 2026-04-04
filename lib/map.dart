// Map module for the neshan_maps_flutter package.
//
// This module provides core map functionality including:
// - Map display widget (NeshanMap)
// - Map configuration (NeshanMapConfig)
// - Map controller (NeshanMapController)
// - Map markers (NeshanMarker)
// - Error callback type (NeshanErrorCallback)
//
// ## Usage
//
// ```dart
// // Import only the map module
// import 'package:neshan_maps_flutter/map.dart';
//
// // Use the map
// NeshanMap(
//   mapKey: 'your-api-key',
//   config: NeshanMapConfig(
//     initialCenter: LatLng(35.6892, 51.3890),
//   ),
// );
// ```

// Core map exports
export 'map/neshan_map.dart';
export 'map/config/neshan_map_config.dart';
export 'map/controller/neshan_map_controller.dart';
export 'map/models/neshan_marker.dart';

// Utilities (NeshanErrorCallback used in public API)
export 'utils/neshan_common.dart';

