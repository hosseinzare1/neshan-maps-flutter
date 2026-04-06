// Location picker configuration classes and builders.
//
// This barrel file exports all configuration-related classes for convenience.
//
// Import this single file to access:
// - NeshanLocationPickerConfig - Timing configuration (debounce durations)
// - LocationPickerUiConfig - UI customization (builders)
// - All builder typedefs and data classes
//
// ## Example
//
// ```dart
// import 'package:neshan_maps_flutter/location_picker.dart';
// import 'package:latlong2/latlong.dart';
//
// NeshanLocationPicker(
//   mapKey: 'your-map-key',
//   reverseGeocodingApiKey: 'geocoding-key',
//   mapConfig: NeshanMapConfig(
//     initialCenter: LatLng(35.6892, 51.3890),
//   ),
//   onLocationAccepted: (position, address) {},
//   locationPickerConfig: NeshanLocationPickerConfig(
//     geocodingDebounce: Duration(milliseconds: 500),
//   ),
//   uiConfig: LocationPickerUiConfig(
//     addressDisplayBuilder: (context, data) => CustomWidget(),
//   ),
// )
// ```
export 'neshan_location_picker_config.dart';
export 'location_picker_ui_config.dart';
export 'location_picker_builders.dart';
