import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../utils/neshan_map_logger.dart';
import '../../../data/error/neshan_api_error.dart';
import '../../../data/reverse_geocoding/models/reverse_geocoding_response.dart';
import '../../../data/reverse_geocoding/neshan_reverse_geocoding_service.dart';
import 'location_picker_state.dart';

/// Controller for managing location picker functionality with ValueNotifier-based state management.
///
/// This controller encapsulates all business logic for the location picker,
/// including location tracking, reverse geocoding with debouncing, error handling,
/// and state management.
///
/// Example usage:
/// ```dart
/// final controller = LocationPickerController(
///   reverseGeocodingApiKey: 'your-api-key',
///   enableDebug: true,
///   debounceDelay: Duration(milliseconds: 500),
/// );
///
/// // Listen to state changes
/// controller.state.addListener(() {
///   print('State changed: ${controller.state.value}');
/// });
///
/// // Handle location change
/// controller.onLocationChanged(35.6892, 51.3890);
///
/// // Clean up
/// controller.dispose();
/// ```
class LocationPickerController {
  /// Creates a [LocationPickerController] instance.
  ///
  /// [reverseGeocodingApiKey] - The Neshan API key for geocoding service. If null, geocoding is disabled.
  /// [enableDebug] - Whether to enable debug logging.
  /// [debounceDelay] - Delay before triggering geocoding after location change.
  /// [onAddressChanged] - Optional callback when address is fetched.
  /// [onApiError] - Optional callback for handling API errors.
  /// [onError] - Optional callback for handling unexpected errors.
  LocationPickerController({
    String? reverseGeocodingApiKey,
    bool enableDebug = false,
    Duration debounceDelay = const Duration(milliseconds: 500),
    void Function(String address, ReverseGeocodingResponse response)?
        onAddressChanged,
    void Function(NeshanApiError error)? onApiError,
    void Function(String message, Exception exception, StackTrace stackTrace)?
        onError,
  })  : _debounceDelay = debounceDelay,
        _onAddressChanged = onAddressChanged,
        _onApiError = onApiError,
        _onError = onError,
        _logger = NeshanMapLogger(
          enabled: enableDebug,
          prefix: 'LocationPickerController',
        ) {
    if (reverseGeocodingApiKey != null) {
      _geocodingService = NeshanReverseGeocodingService(
        apiKey: reverseGeocodingApiKey,
        logger: _logger.withPrefix('Geocoding'),
      );
      _logger.log('Geocoding service initialized');
    } else {
      _logger.log('Geocoding service disabled (no API key provided)');
    }
  }

  /// The reactive state holder.
  final ValueNotifier<LocationPickerState> state = ValueNotifier(
    const LocationPickerState.initial(),
  );

  NeshanReverseGeocodingService? _geocodingService;
  final NeshanMapLogger _logger;
  final Duration _debounceDelay;
  final void Function(String address, ReverseGeocodingResponse response)?
      _onAddressChanged;
  final void Function(NeshanApiError error)? _onApiError;
  final void Function(String message, Exception exception, StackTrace stackTrace)?
      _onError;

  Timer? _debounceTimer;

  /// Handles location changes from the map.
  ///
  /// This method updates the location in state, marks first location as received,
  /// and triggers reverse geocoding if enabled.
  ///
  /// [lat] - The new latitude.
  /// [lng] - The new longitude.
  void onLocationChanged(double lat, double lng) {
    _logger.log('Location changed: ($lat, $lng)');

    // Update state with new location
    if (!state.value.hasReceivedFirstLocation) {
      _logger.log('First location received');
      state.value = state.value.locationReceived(lat, lng);
    } else {
      state.value = state.value.copyWith(
        currentLat: lat,
        currentLng: lng,
      );
    }

    // Trigger reverse geocoding if service is available
    if (_geocodingService != null) {
      _triggerReverseGeocoding(lat, lng);
    }
  }

  /// Triggers reverse geocoding with debouncing.
  ///
  /// Cancels any pending geocoding request and schedules a new one
  /// after the debounce delay.
  ///
  /// [lat] - The latitude to geocode.
  /// [lng] - The longitude to geocode.
  void _triggerReverseGeocoding(double lat, double lng) {
    _logger.log('Triggering reverse geocoding for: ($lat, $lng)');

    // Cancel existing debounce timer
    _debounceTimer?.cancel();

    // Set loading state
    state.value = state.value.loadingAddress();

    _logger.log(
      'Debouncing geocoding request for ${_debounceDelay.inMilliseconds}ms',
    );

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDelay, () async {
      await _fetchAddress(lat, lng);
    });
  }

  /// Performs the actual reverse geocoding API call.
  ///
  /// [lat] - The latitude to geocode.
  /// [lng] - The longitude to geocode.
  Future<void> _fetchAddress(double lat, double lng) async {
    if (_geocodingService == null) return;

    try {
      final response = await _geocodingService!.reverseGeocode(lat, lng);

      _logger.log(
        'Address fetched successfully: ${response.formattedAddress}',
      );

      // Update state with success
      state.value = state.value.geocodingSuccess(
        response.formattedAddress,
        response,
      );

      // Trigger callback
      _onAddressChanged?.call(response.formattedAddress, response);
    } on NeshanApiError catch (e) {
      _logger.error('Geocoding error: ${e.message}', e);

      // Update state with error
      state.value = state.value.geocodingError();

      // Trigger error callback
      _onApiError?.call(e);

      debugPrint('LocationPickerController: Geocoding error: ${e.message}');
    } catch (e, stackTrace) {
      // Handle unexpected non-API errors
      _logger.error('Unexpected error during geocoding', e);

      // Update state with error
      state.value = state.value.geocodingError();

      // Trigger generic error callback
      _onError?.call(
        'Unexpected error during geocoding',
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );

      debugPrint('LocationPickerController: Unexpected error: $e');
    }
  }

  /// Updates the address manually (e.g., from search results).
  ///
  /// This bypasses reverse geocoding and directly sets the address.
  ///
  /// [lat] - The location latitude.
  /// [lng] - The location longitude.
  /// [address] - The formatted address.
  /// [response] - The full geocoding response.
  void updateAddress(
    double lat,
    double lng,
    String address,
    ReverseGeocodingResponse response,
  ) {
    _logger.log('Manually updating address: $address at ($lat, $lng)');

    // Cancel any pending geocoding
    _debounceTimer?.cancel();

    // Update state
    state.value = LocationPickerState(
      currentLat: lat,
      currentLng: lng,
      hasReceivedFirstLocation: true,
      currentAddress: address,
      lastReverseGeocodingResponse: response,
      isLoadingAddress: false,
      hasAddressError: false,
    );

    // Trigger callback
    _onAddressChanged?.call(address, response);
  }

  /// Clears only the error state.
  void clearError() {
    if (state.value.hasAddressError) {
      state.value = state.value.copyWith(hasAddressError: false);
    }
  }

  /// Disposes of resources used by this controller.
  ///
  /// This method should be called when the controller is no longer needed,
  /// typically in the widget's dispose method.
  void dispose() {
    _debounceTimer?.cancel();
    _geocodingService?.dispose();
    state.dispose();
    _logger.log('LocationPickerController disposed');
  }
}

