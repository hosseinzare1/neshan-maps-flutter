import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../../config/location_picker_builders.dart';
import '../../../config/location_picker_ui_config.dart';
import 'default_widgets.dart';

/// Widget that displays the accept location button below the map.
///
/// This widget shows a button to confirm the selected location.
/// It can be customized via the optional [customBuilder].
class PickerAcceptButton extends StatelessWidget {
  /// Creates a [PickerAcceptButton] widget.
  ///
  /// [data] - The accept button data containing enabled state and callbacks.
  /// [customBuilder] - Optional custom builder function from [LocationPickerUiConfig].
  /// If null, uses the default accept button implementation.
  const PickerAcceptButton({
    super.key,
    required this.data,
    this.customBuilder,
  });

  /// The accept button data.
  final AcceptButtonData data;

  /// Optional custom builder for the accept button.
  final AcceptButtonBuilder? customBuilder;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: data.isEnabled || (data.currentLocation != null) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        // Wrap both custom and default widgets with PointerInterceptor
        child: PointerInterceptor(
          child: customBuilder?.call(context, data) ??
              DefaultAcceptButton(data: data),
        ),
      ),
    );
  }
}

