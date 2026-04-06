import 'package:flutter/material.dart';
import '../../../config/location_picker_builders.dart';
import 'default_widgets.dart';

/// Widget that displays the center marker for location picking.
///
/// This widget shows a marker at the center of the map to indicate
/// the currently selected location. It can be customized via the
/// optional [customBuilder].
class PickerCenterMarker extends StatelessWidget {
  /// Creates a [PickerCenterMarker] widget.
  ///
  /// [customBuilder] - Optional custom builder function from [LocationPickerUiConfig].
  /// If null, uses the default center marker implementation.
  const PickerCenterMarker({super.key, this.customBuilder});

  /// Optional custom builder for the center marker.
  final CenterMarkerBuilder? customBuilder;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: customBuilder?.call(context) ?? const DefaultCenterMarker(),
    );
  }
}
