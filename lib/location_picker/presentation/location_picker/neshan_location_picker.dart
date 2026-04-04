import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../map/neshan_map.dart';
import '../../../map/controller/neshan_map_controller.dart';
import '../../../map/config/neshan_map_config.dart';
import '../../../utils/neshan_map_logger.dart';
import '../../../utils/neshan_common.dart';
import '../../config/neshan_location_picker_config.dart';
import '../../config/location_picker_builders.dart';
import '../../config/location_picker_ui_config.dart';
import '../../data/error/neshan_api_error.dart';
import '../../data/reverse_geocoding/models/reverse_geocoding_response.dart';
import '../../data/search/models/search_models.dart';
import '../search/search_screen.dart';
import 'manager/location_picker_controller.dart';
import 'widgets/picker_accept_button.dart';
import 'widgets/picker_address_display.dart';
import 'widgets/picker_center_marker.dart';

/// A location picker widget that wraps NeshanMap with reverse-geocoding and search features.
///
/// This widget provides a complete location selection experience by combining:
/// - Core map display (via NeshanMap)
/// - Optional reverse geocoding to show addresses
/// - Optional address search functionality
/// - Accept location button
///
/// ## Basic Usage
///
/// ```dart
/// NeshanLocationPicker(
///   mapKey: 'your-neshan-map-api-key',
///   mapConfig: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   onLocationAccepted: (position, address) {
///     print('Selected: $address at ${position.latitude}, ${position.longitude}');
///   },
/// )
/// ```
///
/// ## With Reverse Geocoding
///
/// ```dart
/// NeshanLocationPicker(
///   mapKey: 'your-map-key',
///   reverseGeocodingApiKey: 'your-geocoding-key', // Enables address display
///   mapConfig: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   onLocationAccepted: (position, address) {
///     print('Selected: $address at ${position.latitude}, ${position.longitude}');
///   },
/// )
/// ```
///
/// ## With Search and Geocoding
///
/// ```dart
/// NeshanLocationPicker(
///   mapKey: 'your-map-key',
///   reverseGeocodingApiKey: 'your-geocoding-key', // Enables address display
///   searchApiKey: 'your-search-key', // Enables search button
///   mapConfig: NeshanMapConfig(
///     initialCenter: LatLng(35.6892, 51.3890),
///     initialZoom: 15.0,
///   ),
///   config: NeshanLocationPickerConfig(
///     geocodingDebounce: Duration(milliseconds: 500),
///     searchDebounce: Duration(milliseconds: 400),
///   ),
///   onLocationAccepted: (position, address) {
///     print('Selected: $address at ${position.latitude}, ${position.longitude}');
///   },
/// )
/// ```
class NeshanLocationPicker extends StatefulWidget {
  /// Creates a Neshan location picker widget.
  ///
  /// **Required Parameters:**
  /// - [mapKey] - The Neshan API key for displaying the map
  ///
  /// **Map Configuration:**
  /// - [mapConfig] - Configuration for the base map (initial position, zoom, etc.)
  /// - [controller] - Optional controller for programmatic map control
  ///
  /// **Feature Enablement (via API Keys):**
  /// - [reverseGeocodingApiKey] - Provide to enable address display. Without this,
  ///   no address will be shown.
  /// - [searchApiKey] - Provide to enable search functionality. Requires
  ///   [reverseGeocodingApiKey] to also be set.
  ///
  /// **Timing Configuration:**
  /// - [locationPickerConfig] - Optional timing configuration (debounce durations)
  ///
  /// **UI Customization:**
  /// - [uiConfig] - Optional UI customization (custom builders)
  ///
  /// **Callbacks:**
  /// - [onLocationAccepted] - Called when user accepts a location
  /// - [onLocationChanged] - Called when map center changes
  /// - [onAddressChanged] - Called when address is fetched (geocoding)
  /// - [onApiError] - Called when any Neshan API error occurs
  /// - [onError] - Called for general errors
  ///
  /// **Debug:**
  /// - [enableDebug] - Enable detailed logging
  const NeshanLocationPicker({
    super.key,
    required this.mapKey,
    this.mapConfig,
    this.controller,
    this.reverseGeocodingApiKey,
    this.searchApiKey,
    this.locationPickerConfig,
    this.uiConfig,
    this.onLocationAccepted,
    this.onLocationChanged,
    this.onAddressChanged,
    this.onApiError,
    this.onError,
    this.enableDebug = false,
  });

  /// The Neshan API key required to display the map.
  ///
  /// Get your API key from: https://platform.neshan.org/
  final String mapKey;

  /// Configuration for the base map.
  ///
  /// Includes settings like initial center position, zoom level, traffic layer, etc.
  /// If not provided, uses default values (Tehran center, zoom 13).
  final NeshanMapConfig? mapConfig;

  /// Optional controller for programmatic map control.
  ///
  /// Allows you to programmatically:
  /// - Move the map to a specific location
  /// - Add/remove markers
  /// - Control zoom level
  ///
  /// If not provided, an internal controller will be created.
  final NeshanMapController? controller;

  /// API key for Neshan reverse-geocoding service.
  ///
  /// **When provided:** Enables address display at the top of the map.
  /// As the user moves the map, addresses will be automatically fetched and displayed.
  ///
  /// **When null:** No address display will be shown.
  ///
  /// Get your API key from: https://platform.neshan.org/
  final String? reverseGeocodingApiKey;

  /// API key for Neshan search service.
  ///
  /// **When provided (with reverseGeocodingApiKey):** Enables the search button
  /// on the address display. Users can tap it to search for locations.
  ///
  /// **When null:** No search functionality will be available.
  ///
  /// **Note:** Requires [reverseGeocodingApiKey] to also be set, since search
  /// results need to display addresses.
  ///
  /// Get your API key from: https://platform.neshan.org/
  final String? searchApiKey;

  /// Optional timing configuration for debounce durations.
  ///
  /// Controls how long to wait before making API calls after user actions
  /// (moving the map, typing in search).
  ///
  /// If not provided, uses default values (300ms for both).
  final NeshanLocationPickerConfig? locationPickerConfig;

  /// Callback that is called when the accept location button is pressed.
  ///
  /// Provides both the position (LatLng) and the formatted address string.
  final void Function(LatLng position, String address)? onLocationAccepted;

  /// Callback that is called when the map center changes.
  ///
  /// Called whenever the user moves the map or when the map is moved programmatically.
  final void Function(double lat, double lng)? onLocationChanged;

  /// Callback that is called when an address is fetched from reverse-geocoding.
  ///
  /// Only called when [reverseGeocodingApiKey] is provided.
  /// Provides both the formatted address string and the full response object.
  final void Function(String address, ReverseGeocodingResponse response)?
  onAddressChanged;

  /// Callback that is called when any Neshan API error occurs.
  ///
  /// This includes errors from:
  /// - Reverse geocoding service
  /// - Search service
  final void Function(NeshanApiError error)? onApiError;

  /// Callback that is called when a general error occurs.
  final NeshanErrorCallback? onError;

  /// Optional UI customization configuration.
  ///
  /// Contains builder functions for customizing the three core UI components:
  /// - Address display (top of map)
  /// - Accept button (bottom of map)
  /// - Center marker
  ///
  /// If null, all components use their default implementations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// NeshanLocationPicker(
  ///   mapKey: 'key',
  ///   reverseGeocodingApiKey: 'geocoding-key',
  ///   uiConfig: LocationPickerUiConfig(
  ///     addressDisplayBuilder: (context, data) {
  ///       return CustomAddressCard(
  ///         address: data.formattedAddress,
  ///         city: data.fullResponse?.city,
  ///         isLoading: data.isLoading,
  ///       );
  ///     },
  ///     acceptButtonBuilder: (context, data) {
  ///       return CustomButton(onPressed: data.onPressed);
  ///     },
  ///     centerMarkerBuilder: (context) {
  ///       return Icon(Icons.place, size: 48, color: Colors.red);
  ///     },
  ///   ),
  /// )
  /// ```
  final LocationPickerUiConfig? uiConfig;

  /// Whether to enable debug logging for the location picker.
  ///
  /// When enabled, the location picker will print detailed debug information to
  /// the console, including reverse-geocoding requests/responses, search operations,
  /// and location changes.
  ///
  /// Defaults to `false`.
  final bool enableDebug;

  @override
  State<NeshanLocationPicker> createState() => _NeshanLocationPickerState();
}

class _NeshanLocationPickerState extends State<NeshanLocationPicker> {
  // Location picker controller for state management
  late final LocationPickerController _locationPickerController;

  // Map controller - uses external if provided, otherwise creates internal one
  late final NeshanMapController _mapController;
  late final bool _ownsMapController; // Track if we created the controller

  // Logger
  late final NeshanMapLogger _logger;

  // Computed properties for feature enablement
  bool get _isGeocodingEnabled => widget.reverseGeocodingApiKey != null;
  bool get _isSearchEnabled =>
      widget.searchApiKey != null && _isGeocodingEnabled;

  @override
  void initState() {
    super.initState();
    _logger = NeshanMapLogger(
      enabled: widget.enableDebug,
      prefix: 'LocationPicker',
    );
    _logger.log('Initializing NeshanLocationPicker');

    // Get timing config or use defaults
    final config = widget.locationPickerConfig ?? const NeshanLocationPickerConfig();

    // Initialize location picker controller
    _locationPickerController = LocationPickerController(
      reveseGeocodingApiKey: widget.reverseGeocodingApiKey,
      enableDebug: widget.enableDebug,
      debounceDelay: config.geocodingDebounce,
      onAddressChanged: widget.onAddressChanged,
      onApiError: widget.onApiError,
      onError: widget.onError,
    );

    // Use external map controller if provided, otherwise create internal one
    _ownsMapController = widget.controller == null;
    _mapController = widget.controller ?? NeshanMapController();
  }

  @override
  void dispose() {
    _locationPickerController.dispose();
    // Only dispose map controller if we created it
    if (_ownsMapController) {
      _mapController.dispose();
    }
    super.dispose();
  }

  void _handleLocationChanged(double lat, double lng) {
    _logger.log('Location changed: ($lat, $lng)');

    // Delegate to controller for state management
    _locationPickerController.onLocationChanged(lat, lng);

    // Notify external callback
    widget.onLocationChanged?.call(lat, lng);
  }

  Future<void> _openSearchScreen() async {
    if (!_isSearchEnabled) {
      _logger.log('Search attempted but not enabled (missing API key)');
      return;
    }

    _logger.log('Opening search screen');
    final config = widget.locationPickerConfig ?? const NeshanLocationPickerConfig();

    // Use current location from controller state or fallback to initial center
    final state = _locationPickerController.state.value;
    final mapConfig = widget.mapConfig ?? const NeshanMapConfig();
    final lat = state.currentLat ?? mapConfig.initialCenter.latitude;
    final lng = state.currentLng ?? mapConfig.initialCenter.longitude;

    final result = await Navigator.push<SearchItem>(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          apiKey: widget.searchApiKey!,
          currentLat: lat,
          currentLng: lng,
          initialAddress: state.currentAddress,
          enableDebug: widget.enableDebug,
          onApiError: widget.onApiError,
          searchDebounce: config.searchDebounce,
        ),
      ),
    );

    if (result != null && mounted) {
      _logger.log(
        'Search result selected: ${result.title} at (${result.location.y}, ${result.location.x})',
      );
      // Update map location using the map controller
      _mapController.moveToLocation(
        result.location.y,
        result.location.x,
        zoom: 15,
      );

      // Update address through the location picker controller
      _locationPickerController.updateAddress(
        result.location.y,
        result.location.x,
        result.address,
        ReverseGeocodingResponse(
          status: 'OK',
          formattedAddress: result.address,
          city: result.region.split('،').first,
          state: result.region.split('،').last,
          inTrafficZone: false,
          inOddEvenZone: false,
          neighbourhood: result.neighbourhood,
        ),
      );
    } else if (result == null) {
      _logger.log('Search screen closed without selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapConfig = widget.mapConfig ?? const NeshanMapConfig();

    return ValueListenableBuilder(
      valueListenable: _locationPickerController.state,
      builder: (context, state, child) {
        return Stack(
          children: [
            // Core map widget
            NeshanMap(
              mapKey: widget.mapKey,
              controller: _mapController,
              config: mapConfig,
              onLocationChanged: _handleLocationChanged,
              onError: widget.onError,
              enableDebug: widget.enableDebug,
            ),

            // Center marker overlay for location selection
            // Show only after first location update (when map is ready)
            if (state.hasReceivedFirstLocation)
              PickerCenterMarker(
                customBuilder: widget.uiConfig?.centerMarkerBuilder,
              ),

            // Address display overlay (positioned above map)
            // Only show if geocoding is enabled
            if (_isGeocodingEnabled)
              PickerAddressDisplay(
                data: AddressDisplayData(
                  formattedAddress: state.currentAddress,
                  fullResponse: state.lastReverseGeocodingResponse,
                  isLoading: state.isLoadingAddress,
                  hasError: state.hasAddressError,
                  openSearchScreen: _openSearchScreen,
                  isSearchEnabled: _isSearchEnabled,
                ),
                customBuilder: widget.uiConfig?.addressDisplayBuilder,
              ),

            // Accept button overlay (positioned above map)
            if (widget.onLocationAccepted != null)
              PickerAcceptButton(
                data: AcceptButtonData(
                  onPressed: state.isReadyToAccept
                      ? () {
                          widget.onLocationAccepted?.call(
                            LatLng(state.currentLat!, state.currentLng!),
                            state.currentAddress!,
                          );
                        }
                      : null,
                  isEnabled: state.isReadyToAccept,
                  currentLocation: state.hasLocation
                      ? LatLng(state.currentLat!, state.currentLng!)
                      : null,
                  currentAddress: state.currentAddress,
                ),
                customBuilder: widget.uiConfig?.acceptButtonBuilder,
              ),
          ],
        );
      },
    );
  }
}
