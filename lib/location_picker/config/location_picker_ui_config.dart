import 'location_picker_builders.dart';

/// UI configuration for NeshanLocationPicker.
///
/// Contains builder functions for customizing the three core UI components:
/// - Address display widget (top of map)
/// - Accept button (bottom of map)
/// - Center marker (indicates selected location)
///
/// Pass this to [NeshanLocationPicker.uiConfig] parameter.
/// All builders are optional - if null, default implementations will be used.
///
/// ## Example - Custom Address Display
///
/// ```dart
/// LocationPickerUiConfig(
///   addressDisplayBuilder: (context, data) {
///     return Container(
///       padding: EdgeInsets.all(16),
///       decoration: BoxDecoration(
///         color: Colors.white,
///         borderRadius: BorderRadius.circular(12),
///       ),
///       child: Column(
///         crossAxisAlignment: CrossAxisAlignment.start,
///         children: [
///           if (data.isLoading)
///             CircularProgressIndicator(),
///           if (data.formattedAddress != null)
///             Text(data.formattedAddress!),
///           if (data.fullResponse?.city != null)
///             Text('City: ${data.fullResponse!.city}'),
///         ],
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Example - Custom Accept Button
///
/// ```dart
/// LocationPickerUiConfig(
///   acceptButtonBuilder: (context, data) {
///     return ElevatedButton.icon(
///       onPressed: data.onPressed,
///       icon: Icon(Icons.check),
///       label: Text('Confirm ${data.currentAddress ?? "Location"}'),
///       style: ElevatedButton.styleFrom(
///         padding: EdgeInsets.symmetric(vertical: 16),
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Example - Custom Marker
///
/// ```dart
/// LocationPickerUiConfig(
///   centerMarkerBuilder: (context) {
///     return Icon(
///       Icons.location_pin,
///       size: 48,
///       color: Colors.red,
///     );
///   },
/// )
/// ```
class LocationPickerUiConfig {
  /// Creates a UI configuration for location picker.
  const LocationPickerUiConfig({
    this.addressDisplayBuilder,
    this.acceptButtonBuilder,
    this.centerMarkerBuilder,
  });

  /// Optional builder for the address display widget at the top of the map.
  ///
  /// The builder receives [AddressDisplayData] containing:
  /// - `formattedAddress`: The current address string
  /// - `fullResponse`: Complete reverse-geocoding response (city, state, neighbourhood, etc.)
  /// - `isLoading`: Whether address is being fetched
  /// - `hasError`: Whether reverse-geocoding failed
  /// - `onTap`: Callback to open search (only if search is enabled)
  /// - `isSearchEnabled`: Whether search feature is active
  ///
  /// If null, uses the default address display implementation.
  final AddressDisplayBuilder? addressDisplayBuilder;

  /// Optional builder for the accept button at the bottom of the map.
  ///
  /// The builder receives [AcceptButtonData] containing:
  /// - `onPressed`: Callback when button is pressed (null when disabled)
  /// - `isEnabled`: Whether button should be enabled
  /// - `currentLocation`: The selected location coordinates
  /// - `currentAddress`: The selected address string
  ///
  /// If null, uses the default accept button implementation.
  final AcceptButtonBuilder? acceptButtonBuilder;

  /// Optional builder for the center marker indicating the selected location.
  ///
  /// The builder receives just [BuildContext].
  ///
  /// If null, uses the default pin marker.
  final CenterMarkerBuilder? centerMarkerBuilder;
}
