import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../../config/location_picker_builders.dart';
import '../../../config/location_picker_ui_config.dart';
import 'default_widgets.dart';

/// Widget that displays the address information above the map.
///
/// This widget shows the current address fetched from reverse geocoding,
/// or loading/error states. It can be customized via the optional [customBuilder].
class PickerAddressDisplay extends StatelessWidget {
  /// Creates a [PickerAddressDisplay] widget.
  ///
  /// [data] - The address display data containing address, loading, and error states.
  /// [customBuilder] - Optional custom builder function from [LocationPickerUiConfig].
  /// If null, uses the default address display implementation.
  const PickerAddressDisplay({
    super.key,
    required this.data,
    this.customBuilder,
  });

  /// The address display data.
  final AddressDisplayData data;

  /// Optional custom builder for the address display.
  final AddressDisplayBuilder? customBuilder;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: (data.isLoading || data.formattedAddress != null || data.hasError)
            ? 1.0
            : 0.0,
        duration: const Duration(milliseconds: 300),
        // Wrap both custom and default widgets with PointerInterceptor
        child: PointerInterceptor(
          child: customBuilder?.call(context, data) ??
              DefaultAddressDisplay(data: data),
        ),
      ),
    );
  }
}

