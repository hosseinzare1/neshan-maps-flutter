/// Location picker module for the neshan_maps_flutter package.
///
/// This module provides location picking functionality including:
/// - Location picker widget ([NeshanLocationPicker])
/// - Location picker configuration ([NeshanLocationPickerConfig])
/// - Map configuration ([NeshanMapConfig]) for configuring the underlying map
/// - Reverse geocoding models ([ReverseGeocodingResponse])
/// - API error handling ([NeshanApiError])
/// - Error callbacks on the map and picker widgets
///
/// **Note:** This library re-exports [NeshanMapConfig] and [NeshanMapType] for
/// configuring the picker’s map. For [NeshanMap], [NeshanMapController], and
/// [NeshanMarker], import `package:neshan_maps_flutter/map.dart`.
///
/// ## Usage
///
/// ```dart
/// import 'package:neshan_maps_flutter/location_picker.dart';
/// import 'package:latlong2/latlong.dart';
///
/// NeshanLocationPicker(
///   mapKey: 'your-map-api-key',
///   reverseGeocodingApiKey: 'your-reverse-geocoding-key',
///   mapConfig: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///   ),
///   onLocationAccepted: (position, address) {
///     print('Selected: $address at ${position.latitude}, ${position.longitude}');
///   },
/// );
/// ```
library;

// Location picker exports
export 'src/location_picker/presentation/location_picker/neshan_location_picker.dart';
export 'src/location_picker/config/neshan_location_picker_config.dart';
export 'src/location_picker/config/location_picker_config.dart';
export 'src/location_picker/data/reverse_geocoding/models/reverse_geocoding_response.dart';
export 'src/location_picker/data/error/neshan_api_error.dart';

// Map exports (needed for NeshanMapConfig used in location picker)
export 'src/map/config/neshan_map_config.dart';
