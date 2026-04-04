import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// A model representing a marker on a Neshan map.
///
/// This class encapsulates all the properties needed to display a marker
/// using the Neshan SDK's `nmp_mapboxgl.Marker` API.
///
/// ## Usage Example
///
/// ```dart
/// final marker = NeshanMarker(
///   id: 'marker1',
///   position: LatLng(35.6892, 51.3890),
///   color: Colors.red,
///   title: 'Tehran',
///   draggable: false,
/// );
/// ```
class NeshanMarker {
  /// Creates a new marker.
  ///
  /// [id] is a unique identifier for the marker.
  /// [position] is the location where the marker should be displayed.
  /// [color] is an optional [Color] object (e.g., `Colors.red`, or null for default).
  /// [draggable] determines whether the marker can be dragged (default: false).
  /// [title] is optional text to display in a popup when the marker is tapped.
  const NeshanMarker({
    required this.id,
    required this.position,
    this.color,
    this.draggable = false,
    this.title,
  });

  /// Unique identifier for the marker.
  final String id;

  /// The location where the marker should be displayed.
  final LatLng position;

  /// Optional color for the marker.
  ///
  /// Can be any Flutter [Color] object (e.g., `Colors.red`, `Color(0xFFFF0000)`),
  /// or null to use the default marker color.
  final Color? color;

  /// Whether the marker can be dragged by the user.
  final bool draggable;

  /// Optional title text to display in a popup.
  final String? title;

  /// Converts the [Color] to a string format compatible with the Neshan SDK.
  ///
  /// Returns:
  /// - RGBA format (e.g., "rgba(255, 0, 0, 0.5)") if opacity is less than 1.0
  /// - Hex format (e.g., "#FF0000") if opacity is 1.0 (fully opaque)
  ///
  /// Returns null if [color] is null.
  String? toColorString() {
    if (color == null) return null;

    final opacity = color!.a;
    final red = (color!.r * 255.0).round().clamp(0, 255);
    final green = (color!.g * 255.0).round().clamp(0, 255);
    final blue = (color!.b * 255.0).round().clamp(0, 255);

    // Use RGBA format if opacity is not fully opaque
    if (opacity < 1.0) {
      return 'rgba($red, $green, $blue, ${opacity.toStringAsFixed(2)})';
    }

    // Use hex format for fully opaque colors
    return '#${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }

  /// Converts this marker to a JSON object for serialization.
  ///
  /// This is used to pass marker data to the HTML map view.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': position.latitude,
      'lng': position.longitude,
      if (color != null) 'color': toColorString(),
      'draggable': draggable,
      if (title != null) 'title': title,
    };
  }

  @override
  String toString() {
    return 'NeshanMarker(id: $id, position: $position, color: $color, draggable: $draggable, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NeshanMarker &&
        other.id == id &&
        other.position == position &&
        other.color == color &&
        other.draggable == draggable &&
        other.title == title;
  }

  @override
  int get hashCode {
    return Object.hash(id, position, color, draggable, title);
  }
}
