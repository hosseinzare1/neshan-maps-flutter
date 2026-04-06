// Location picker module for the neshan_maps_flutter package.
//
// This module provides location picking functionality including:
// - Location picker widget (NeshanLocationPicker)
// - Location picker configuration (NeshanLocationPickerConfig)
// - Map configuration (NeshanMapConfig) - for configuring the underlying map
// - Reverse geocoding models (ReverseGeocodingResponse)
// - API error handling (NeshanApiError)
// - Error callback type (NeshanErrorCallback)
//
// **Note**: This module depends on the map module. If you use this module,
// you don't need to separately import the map module as it's included.
//
// ## Usage
//
// ```dart
// // Import only the location picker module
// import 'package:neshan_maps_flutter/location_picker.dart';
//
// // Use the location picker
// NeshanLocationPicker(
//   mapKey: 'your-api-key',
//   mapConfig: NeshanMapConfig(
//     initialCenter: LatLng(35.6892, 51.3890),
//   ),
//   onLocationSelected: (location) {
//     print('Selected: ${location.address}');
//   },
// );
// ```

// Location picker exports
export 'src/location_picker/presentation/location_picker/neshan_location_picker.dart';
export 'src/location_picker/config/neshan_location_picker_config.dart';
export 'src/location_picker/data/reverse_geocoding/models/reverse_geocoding_response.dart';
export 'src/location_picker/data/error/neshan_api_error.dart';


// Map exports (needed for NeshanMapConfig used in location picker)
export 'src/map/config/neshan_map_config.dart';
