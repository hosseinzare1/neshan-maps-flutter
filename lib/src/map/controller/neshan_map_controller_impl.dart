import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:latlong2/latlong.dart';

import '../models/neshan_marker.dart';

// Conditional imports
// webview_flutter only available on mobile (not web)
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.js_interop) 'neshan_map_controller_stub.dart';

// Web implementation import - only on web
import 'neshan_map_controller_web.dart'
    if (dart.library.io) 'neshan_map_controller_stub.dart'
    as web_impl;

import 'neshan_map_controller_base.dart';

/// Creates the appropriate controller implementation based on platform.
NeshanMapControllerImpl createController() {
  if (kIsWeb) {
    return web_impl.createWebController();
  } else {
    return _MobileMapControllerImpl();
  }
}

/// Mobile implementation using WebView JavaScript execution.
class _MobileMapControllerImpl extends NeshanMapControllerImpl {
  WebViewController? _webViewController;

  @override
  void setWebViewController(dynamic controller) {
    logger.log('setWebViewController called');
    _webViewController = controller as WebViewController;
    logger.log('WebViewController set: ${_webViewController != null}');
    markReady();
  }

  @override
  void moveToLocation(double lat, double lng, {double? zoom}) {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot move to location');
      return;
    }

    logger.log(
      'Moving to location: ($lat, $lng)${zoom != null ? ', zoom: $zoom' : ''}',
    );
    final zoomValue = zoom != null ? zoom.toString() : 'map.getZoom()';
    final script =
        '''
      (function() {
        const map = window.neshanMap;
        if (map && typeof map.flyTo === 'function') {
          map.flyTo({
            center: [$lng, $lat],
            zoom: $zoomValue
          });
        } else {
          console.error('NeshanMap: map is not available');
        }
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  void setZoom(double zoom) {
    if (_webViewController == null) {
      return;
    }

    final script =
        '''
      (function() {
        const map = window.neshanMap;
        if (map && typeof map.flyTo === 'function') {
          map.flyTo({
            zoom: $zoom
          });
        }
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    if (_webViewController == null) {
      return null;
    }

    final script = '''
      (function() {
        const map = window.neshanMap;
        if (map && typeof map.getCenter === 'function') {
          const center = map.getCenter();
          return JSON.stringify({lat: center.lat, lng: center.lng});
        }
        return null;
      })();
    ''';

    try {
      final result = await _webViewController!.runJavaScriptReturningResult(
        script,
      );
      if (result.toString() != 'null') {
        final jsonData = jsonDecode(result.toString()) as Map<String, dynamic>;
        final location = LatLng(
          (jsonData['lat'] as num).toDouble(),
          (jsonData['lng'] as num).toDouble(),
        );
        logger.log(
          'Got current location: (${location.latitude}, ${location.longitude})',
        );
        return location;
      }
    } catch (e) {
      logger.error('Error getting current location', e);
    }
    return null;
  }

  @override
  Future<double?> getCurrentZoom() async {
    if (_webViewController == null) {
      return null;
    }

    final script = '''
      (function() {
        const map = window.neshanMap;
        if (map && typeof map.getZoom === 'function') {
          return map.getZoom();
        }
        return null;
      })();
    ''';

    try {
      final result = await _webViewController!.runJavaScriptReturningResult(
        script,
      );
      if (result.toString() != 'null') {
        final zoom = double.tryParse(result.toString());
        logger.log('Got current zoom: $zoom');
        return zoom;
      }
    } catch (e) {
      logger.error('Error getting current zoom', e);
    }
    return null;
  }

  @override
  void fitBounds(double north, double south, double east, double west) {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot fit bounds');
      return;
    }

    logger.log('Fitting bounds: N:$north, S:$south, E:$east, W:$west');
    final script =
        '''
      (function() {
        const map = window.neshanMap;
        if (map && typeof map.fitBounds === 'function') {
          map.fitBounds(
            [[$west, $south], [$east, $north]],
            { padding: 50 }
          );
        }
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  void addMarker(NeshanMarker marker) {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot add marker');
      return;
    }

    logger.log('Adding marker: ${marker.id}');
    final markerJson = jsonEncode(marker.toJson());
    final script =
        '''
      (function() {
        const markerData = $markerJson;
        window.postMessage({
          type: 'addMarker',
          marker: markerData
        }, '*');
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  void removeMarker(String markerId) {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot remove marker');
      return;
    }

    logger.log('Removing marker: $markerId');
    final script =
        '''
      (function() {
        window.postMessage({
          type: 'removeMarker',
          markerId: '$markerId'
        }, '*');
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  void updateMarkers(List<NeshanMarker> markers) {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot update markers');
      return;
    }

    logger.log('Updating ${markers.length} markers');
    final markersJson = jsonEncode(markers.map((m) => m.toJson()).toList());
    final script =
        '''
      (function() {
        const markersData = $markersJson;
        window.postMessage({
          type: 'updateMarkers',
          markers: markersData
        }, '*');
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }

  @override
  void clearMarkers() {
    if (_webViewController == null) {
      logger.log('WebViewController is null, cannot clear markers');
      return;
    }

    logger.log('Clearing all markers');
    final script = '''
      (function() {
        window.postMessage({
          type: 'clearMarkers'
        }, '*');
      })();
    ''';

    _webViewController!.runJavaScript(script);
  }
}
