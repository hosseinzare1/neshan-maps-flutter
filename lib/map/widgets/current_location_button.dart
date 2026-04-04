import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A floating action button that triggers current location tracking.
///
/// This button is typically overlaid on top of a map widget and allows
/// users to center the map on their current location.
///
/// The button displays different icons based on the tracking state:
/// - [Icons.location_searching] when not tracking (gray)
/// - [Icons.my_location] when actively tracking (blue)
///
/// ## Usage Example
///
/// ```dart
/// Stack(
///   children: [
///     MapWidget(),
///     CurrentLocationButton(
///       isTracking: _isTracking,
///       onTap: () {
///         setState(() => _isTracking = !_isTracking);
///         // Start/stop location tracking
///       },
///     ),
///   ],
/// )
/// ```
class CurrentLocationButton extends StatelessWidget {
  /// Creates a current location button.
  ///
  /// [onTap] is called when the button is pressed.
  /// [isTracking] determines the button's visual state (icon and color).
  const CurrentLocationButton({
    super.key,
    required this.onTap,
    this.isTracking = false,
  });

  /// Callback invoked when the button is tapped.
  final VoidCallback onTap;

  /// Whether location tracking is currently active.
  ///
  /// When `true`, the button shows [Icons.my_location] with a blue color.
  /// When `false`, the button shows [Icons.location_searching] with a gray color.
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 64,
      right: 16,
      child: PointerInterceptor(
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: onTap,
          child: Icon(
            isTracking ? Icons.my_location : Icons.location_searching,
            color: isTracking ? Colors.blue : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}
