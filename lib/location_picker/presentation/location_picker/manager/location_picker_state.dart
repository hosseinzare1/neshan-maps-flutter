
import '../../../data/reverse_geocoding/models/reverse_geocoding_response.dart';

/// Immutable state class for location picker functionality.
///
/// This class represents all possible states of the location picker,
/// including location tracking, geocoding results, loading, and error states.
class LocationPickerState {
  /// The current latitude. Null if no location has been received yet.
  final double? currentLat;

  /// The current longitude. Null if no location has been received yet.
  final double? currentLng;

  /// Whether the first location update has been received.
  /// Used to determine when to show the center marker.
  final bool hasReceivedFirstLocation;

  /// The current formatted address from reverse geocoding. Null if no address.
  final String? currentAddress;

  /// The full reverse geocoding response. Null if no geocoding performed.
  final ReverseGeocodingResponse? lastReverseGeocodingResponse;

  /// Whether a reverse-geocoding operation is currently in progress.
  final bool isLoadingAddress;

  /// Whether the last reverse-geocoding attempt resulted in an error.
  final bool hasAddressError;

  /// Creates a [LocationPickerState] instance.
  const LocationPickerState({
    this.currentLat,
    this.currentLng,
    this.hasReceivedFirstLocation = false,
    this.currentAddress,
    this.lastReverseGeocodingResponse,
    this.isLoadingAddress = false,
    this.hasAddressError = false,
  });

  /// Creates an initial empty state.
  const LocationPickerState.initial()
      : currentLat = null,
        currentLng = null,
        hasReceivedFirstLocation = false,
        currentAddress = null,
        lastReverseGeocodingResponse = null,
        isLoadingAddress = false,
        hasAddressError = false;

  /// Creates a state for when location is received but geocoding not started.
  LocationPickerState locationReceived(double lat, double lng) {
    return LocationPickerState(
      currentLat: lat,
      currentLng: lng,
      hasReceivedFirstLocation: true,
      currentAddress: currentAddress,
      lastReverseGeocodingResponse: lastReverseGeocodingResponse,
      isLoadingAddress: false,
      hasAddressError: false,
    );
  }

  /// Creates a loading state while fetching address.
  LocationPickerState loadingAddress() {
    return LocationPickerState(
      currentLat: currentLat,
      currentLng: currentLng,
      hasReceivedFirstLocation: hasReceivedFirstLocation,
      currentAddress: currentAddress,
      lastReverseGeocodingResponse: lastReverseGeocodingResponse,
      isLoadingAddress: true,
      hasAddressError: false,
    );
  }

  /// Creates a success state with geocoding results.
  LocationPickerState geocodingSuccess(
    String address,
    ReverseGeocodingResponse response,
  ) {
    return LocationPickerState(
      currentLat: currentLat,
      currentLng: currentLng,
      hasReceivedFirstLocation: hasReceivedFirstLocation,
      currentAddress: address,
      lastReverseGeocodingResponse: response,
      isLoadingAddress: false,
      hasAddressError: false,
    );
  }

  /// Creates an error state when geocoding fails.
  LocationPickerState geocodingError() {
    return LocationPickerState(
      currentLat: currentLat,
      currentLng: currentLng,
      hasReceivedFirstLocation: hasReceivedFirstLocation,
      currentAddress: null,
      lastReverseGeocodingResponse: null,
      isLoadingAddress: false,
      hasAddressError: true,
    );
  }

  /// Creates a copy of this state with the given fields replaced with new values.
  LocationPickerState copyWith({
    double? currentLat,
    double? currentLng,
    bool? hasReceivedFirstLocation,
    String? currentAddress,
    ReverseGeocodingResponse? lastReverseGeocodingResponse,
    bool? isLoadingAddress,
    bool? hasAddressError,
  }) {
    return LocationPickerState(
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      hasReceivedFirstLocation:
          hasReceivedFirstLocation ?? this.hasReceivedFirstLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      lastReverseGeocodingResponse:
          lastReverseGeocodingResponse ?? this.lastReverseGeocodingResponse,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      hasAddressError: hasAddressError ?? this.hasAddressError,
    );
  }

  /// Whether the state has a valid location.
  bool get hasLocation => currentLat != null && currentLng != null;

  /// Whether the state is ready to accept (has location and address).
  bool get isReadyToAccept =>
      hasLocation && currentAddress != null && !isLoadingAddress;
}

