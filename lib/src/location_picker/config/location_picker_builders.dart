import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/reverse_geocoding/models/reverse_geocoding_response.dart';

// ============ Address Display ============

/// Data provided to [AddressDisplayBuilder].
///
/// Contains all information needed to display the current address
/// and handle user interactions.
class AddressDisplayData {
  /// Creates address-display data passed to [AddressDisplayBuilder].
  ///
  /// All fields are required so custom builders can render a complete UI state.
  const AddressDisplayData({
    required this.formattedAddress,
    required this.fullResponse,
    required this.isLoading,
    required this.hasError,
    required this.openSearchScreen,
    required this.isSearchEnabled,
  });

  /// The formatted address string (e.g., "خیابان آزادی، تهران").
  final String? formattedAddress;

  /// Complete reverse geocoding response with detailed location info.
  ///
  /// Contains: city, state, neighbourhood, inTrafficZone, etc.
  /// Null if reverse-geocoding hasn't completed or failed.
  final ReverseGeocodingResponse? fullResponse;

  /// Whether the address is currently being fetched.
  final bool isLoading;

  /// Whether reverse-geocoding request failed.
  final bool hasError;

  /// Callback to open search screen (null if search is disabled).
  final VoidCallback? openSearchScreen;

  /// Whether search feature is enabled.
  final bool isSearchEnabled;
}

/// Builder function for customizing the address display widget.
///
/// Receives [BuildContext] and [AddressDisplayData].
/// Should return a widget to display at the top of the map.
typedef AddressDisplayBuilder =
    Widget Function(BuildContext context, AddressDisplayData data);

// ============ Accept Button ============

/// Data provided to [AcceptButtonBuilder].
///
/// Contains information about the selected location and button state.
class AcceptButtonData {
  /// Creates accept-button data passed to [AcceptButtonBuilder].
  ///
  /// All fields are required so builders can decide enabled state and behavior.
  const AcceptButtonData({
    required this.onPressed,
    required this.isEnabled,
    required this.currentLocation,
    required this.currentAddress,
  });

  /// Callback when button is pressed.
  ///
  /// Null when button should be disabled (loading or no address).
  final VoidCallback? onPressed;

  /// Whether the button should be enabled.
  final bool isEnabled;

  /// The currently selected location coordinates.
  ///
  /// Null if location hasn't been determined yet.
  final LatLng? currentLocation;

  /// The address string for the current location.
  ///
  /// Null if address hasn't been fetched yet.
  final String? currentAddress;
}

/// Builder function for customizing the accept button widget.
///
/// Receives [BuildContext] and [AcceptButtonData].
/// Should return a widget to display at the bottom of the map.
typedef AcceptButtonBuilder =
    Widget Function(BuildContext context, AcceptButtonData data);

// ============ Center Marker ============

/// Builder function for customizing the center marker.
///
/// Receives [BuildContext].
/// Should return a widget to display at the center of the map indicating
/// the selected location (typically a pin or custom marker icon).
typedef CenterMarkerBuilder = Widget Function(BuildContext context);
