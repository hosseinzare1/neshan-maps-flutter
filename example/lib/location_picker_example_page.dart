import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neshan_maps_flutter/location_picker.dart';

import 'api_keys.dart';

/// Demonstrates [NeshanLocationPicker] with reverse geocoding and optional search.
class LocationPickerExamplePage extends StatelessWidget {
  const LocationPickerExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NeshanLocationPicker example')),
      body: NeshanLocationPicker(
        mapKey: kMapKey,
        reverseGeocodingApiKey: kReverseGeocodingApiKey,
        searchApiKey: kSearchApiKey,
        mapConfig: const NeshanMapConfig(
          initialCenter: LatLng(35.6892, 51.3890),
          initialZoom: 15,
        ),
        onLocationAccepted: (LatLng position, String address) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                address.isEmpty
                    ? '${position.latitude}, ${position.longitude}'
                    : '$address\n${position.latitude}, ${position.longitude}',
              ),
            ),
          );
        },
        onError: (message, exception, stackTrace) {
          debugPrint('Picker error: $message');
        },
      ),
    );
  }
}
