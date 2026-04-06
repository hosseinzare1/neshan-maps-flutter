import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../map/neshan_map.dart';
import '../../../map/controller/neshan_map_controller.dart';
import '../../../map/config/neshan_map_config.dart';
import '../../../map/models/neshan_marker.dart';
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
  /// **Required:**
  /// - [mapKey] — Neshan API key for the map.
  /// - [reverseGeocodingApiKey] — Neshan API key for reverse-geocoding (enables
  ///   the address bar).
  /// - [onLocationAccepted] — Called when the user confirms a location.
  ///
  /// **Map:**
  /// - [mapConfig] — Viewport & style settings ([NeshanMapConfig]).
  /// - [markers] — Static markers to show on the map alongside the centre pin.
  /// - [controller] — Optional [NeshanMapController] for programmatic control.
  ///
  /// **Features (enabled by supplying API keys):**
  /// - [searchApiKey] — Enables the search button (requires
  ///   [reverseGeocodingApiKey], which is always provided).
  ///
  /// **Timing:**
  /// - [locationPickerConfig] — Debounce durations for geocoding & search.
  ///
  /// **UI:**
  /// - [uiConfig] — Custom builders for address display, accept button, and
  ///   centre marker.
  ///
  /// **Callbacks:**
  /// - [onLocationChanged] — Map centre changed.
  /// - [onAddressChanged] — Geocoding returned a new address.
  /// - [onApiError] — A Neshan API call failed.
  /// - [onError] — General error.
  ///
  /// **Debug:**
  /// - [enableDebug] — Verbose console logging.
  const NeshanLocationPicker({
    super.key,
    required this.mapKey,
    required this.reverseGeocodingApiKey,
    required this.onLocationAccepted,
    this.mapConfig,
    this.markers = const [],
    this.controller,
    this.searchApiKey,
    this.locationPickerConfig,
    this.uiConfig,
    this.onLocationChanged,
    this.onAddressChanged,
    this.onApiError,
    this.onError,
    this.enableDebug = false,
  });

  /// The Neshan API key required to display the map.
  ///
  /// Obtain your key at https://platform.neshan.org/.
  final String mapKey;

  /// Viewport and style configuration for the underlying map.
  ///
  /// Controls the initial centre, zoom, map type, traffic layer, etc.
  /// If omitted, the map opens centred on Tehran at zoom 12.
  final NeshanMapConfig? mapConfig;

  /// Static markers to display on the map alongside the centre-pin overlay.
  ///
  /// These markers are placed on the map when it first loads. To add or
  /// remove markers at runtime, use [controller].
  ///
  /// Defaults to an empty list.
  final List<NeshanMarker> markers;

  /// Optional controller for programmatic map control.
  ///
  /// Use this to move the map, change zoom, or manage markers at runtime.
  /// If omitted, an internal controller is created and managed automatically.
  final NeshanMapController? controller;

  /// API key for Neshan reverse-geocoding.
  ///
  /// Enables the address bar at the top of the map. As the user pans, the
  /// address at the centre pin is fetched and displayed automatically.
  ///
  /// Obtain your key at https://platform.neshan.org/.
  final String reverseGeocodingApiKey;

  /// API key for Neshan search.
  ///
  /// **Provided:** Adds a search icon to the address bar. Tapping it opens the
  /// search screen where users can find a location by name.
  ///
  /// **Omitted:** No search functionality is available.
  ///
  /// Obtain your key at https://platform.neshan.org/.
  final String? searchApiKey;

  /// Timing configuration (debounce durations).
  ///
  /// Controls how long the widget waits after the map stops moving before
  /// calling the geocoding API, and how long it waits after the user stops
  /// typing before calling the search API.
  ///
  /// If omitted, defaults to 300 ms for both.
  final NeshanLocationPickerConfig? locationPickerConfig;

  /// Called when the user presses the accept button.
  ///
  /// Receives the selected [LatLng] position and the formatted address string
  /// from reverse-geocoding.
  final void Function(LatLng position, String address) onLocationAccepted;

  /// Called whenever the map centre changes.
  ///
  /// Fired both on user pan and on programmatic moves via [controller].
  final void Function(double lat, double lng)? onLocationChanged;

  /// Called when reverse-geocoding returns a new address.
  ///
  /// Only fired when [reverseGeocodingApiKey] is provided.
  final void Function(String address, ReverseGeocodingResponse response)?
  onAddressChanged;

  /// Called when any Neshan API request fails.
  ///
  /// Covers errors from the reverse-geocoding and search services.
  final void Function(NeshanApiError error)? onApiError;

  /// Called on general (non-API) errors.
  final NeshanErrorCallback? onError;

  /// UI customization for the three overlay widgets.
  ///
  /// Provide custom builders for:
  /// - `addressDisplayBuilder` — The address bar at the top of the map.
  /// - `acceptButtonBuilder` — The confirm button at the bottom.
  /// - `centerMarkerBuilder` — The pin at the centre of the map.
  ///
  /// Any builder left `null` falls back to the default implementation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// NeshanLocationPicker(
  ///   mapKey: 'key',
  ///   reverseGeocodingApiKey: 'geocoding-key',
  ///   uiConfig: LocationPickerUiConfig(
  ///     acceptButtonBuilder: (context, data) => ElevatedButton(
  ///       onPressed: data.onPressed,
  ///       child: const Text('Confirm'),
  ///     ),
  ///     centerMarkerBuilder: (context) =>
  ///         const Icon(Icons.place, size: 48, color: Colors.red),
  ///   ),
  /// )
  /// ```
  final LocationPickerUiConfig? uiConfig;

  /// Enables verbose debug logging to the console.
  ///
  /// Logs reverse-geocoding requests/responses, search operations, and
  /// location changes. Defaults to `false`.
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

  // Search is enabled only when a search API key is provided.
  // Geocoding is always enabled (reverseGeocodingApiKey is required).
  bool get _isSearchEnabled => widget.searchApiKey != null;

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
      reverseGeocodingApiKey: widget.reverseGeocodingApiKey,
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
              markers: widget.markers,
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
            PickerAcceptButton(
              data: AcceptButtonData(
                onPressed: state.isReadyToAccept
                    ? () {
                        widget.onLocationAccepted(
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
