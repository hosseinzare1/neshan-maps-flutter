/// Configuration for timing and behavior settings of the Neshan Location Picker.
///
/// This class contains only timing-related configuration. API keys and map
/// configuration are passed directly to the [NeshanLocationPicker] widget.
///
/// ## Usage Example
///
/// ```dart
/// NeshanLocationPicker(
///   mapKey: 'your-map-api-key',
///   mapConfig: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   reverseGeocodingApiKey: 'your-geocoding-key', // Enables geocoding
///   searchApiKey: 'your-search-key', // Enables search
///   config: NeshanLocationPickerConfig(
///     geocodingDebounce: Duration(milliseconds: 500),
///     searchDebounce: Duration(milliseconds: 400),
///   ),
/// )
/// ```
///
/// ## Default Values
///
/// - **geocodingDebounce**: `Duration(milliseconds: 300)`
/// - **searchDebounce**: `Duration(milliseconds: 300)`
///
/// ## Feature Enablement
///
/// Features are automatically enabled/disabled based on API key availability:
/// - **Reverse Geocoding**: Enabled when `reverseGeocodingApiKey` is provided
/// - **Search**: Enabled when `searchApiKey` is provided
class NeshanLocationPickerConfig {
  /// Creates a location picker configuration.
  ///
  /// [geocodingDebounce] - Debounce duration for reverse-geocoding API calls (default: 300ms).
  /// [searchDebounce] - Debounce duration for search input (default: 300ms).
  const NeshanLocationPickerConfig({
    this.geocodingDebounce = const Duration(milliseconds: 300),
    this.searchDebounce = const Duration(milliseconds: 300),
  });

  /// Debounce duration for reverse-geocoding API calls.
  ///
  /// When the user moves the map, the reverse-geocoding API is not called immediately.
  /// Instead, it waits for this duration after the user stops moving the map
  /// to avoid making too many API requests.
  ///
  /// Default is 300 milliseconds.
  final Duration geocodingDebounce;

  /// Debounce duration for search input.
  ///
  /// When the user types in the search field, the search API is not called
  /// immediately. Instead, it waits for this duration after the user stops
  /// typing to avoid making too many API requests.
  ///
  /// Default is 300 milliseconds.
  final Duration searchDebounce;
}
