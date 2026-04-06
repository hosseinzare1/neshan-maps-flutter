import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neshan_maps_flutter/map.dart';

import 'api_keys.dart';

/// Demonstrates [NeshanMap] with a controller, marker, and programmatic move.
class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  final _controller = NeshanMapController();

  static const _tehran = LatLng(35.6892, 51.3890);
  static const _milad = LatLng(35.7448, 51.3753);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeshanMap example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city_outlined),
            tooltip: 'Move to Milad Tower area',
            onPressed: () async {
             await _controller.ready;
              _controller.moveToLocation(
                _milad.latitude,
                _milad.longitude,
                zoom: 15,
              );
            },
          ),
        ],
      ),
      body: NeshanMap(
        mapKey: kMapKey,
        controller: _controller,
        enableDebug: true,
        config: const NeshanMapConfig(
          initialCenter: _tehran,
          initialZoom: 14,
          showTraffic: true,
        ),
        markers: const [
          NeshanMarker(
            id: 'tehran',
            position: _tehran,
            title: 'Tehran',
            color: Colors.red,
          ),
        ],
        onLocationChanged: (lat, lng) {
          debugPrint('Centre: $lat, $lng');
        },
        onMarkerTapped: (markerId) {
          debugPrint('Marker tapped: $markerId');
        },
        onError: (message, exception, stackTrace) {
          debugPrint('Map error: $message');
        },
      ),
    );
  }
}
