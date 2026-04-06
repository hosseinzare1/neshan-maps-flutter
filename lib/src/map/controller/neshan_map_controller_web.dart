import 'dart:async';
import 'dart:js_interop';

import 'package:latlong2/latlong.dart';
import 'package:web/web.dart' as web;
import 'neshan_map_controller_base.dart';
import '../models/neshan_marker.dart';

/// Creates the web controller implementation.
NeshanMapControllerImpl createWebController() {
  return _WebMapControllerImpl();
}

/// Web implementation using postMessage to iframe.
class _WebMapControllerImpl extends NeshanMapControllerImpl {
  web.HTMLIFrameElement? _iframe;

  @override
  void setIframe(dynamic iframe) {
    logger.log('setIframe called');
    _iframe = iframe as web.HTMLIFrameElement;
    logger.log('iframe set: ${_iframe != null}');
    if (_iframe != null) {
      logger.log('iframe contentWindow: ${_iframe!.contentWindow != null}');
      markReady();
    }
  }

  @override
  void moveToLocation(double lat, double lng, {double? zoom}) {
    if (_iframe == null) {
      logger.log('iframe is null, cannot move to location');
      return;
    }

    if (_iframe!.contentWindow == null) {
      logger.log('iframe contentWindow is null, cannot move to location');
      return;
    }

    logger.log('Moving to location: ($lat, $lng)${zoom != null ? ', zoom: $zoom' : ''}');
    final message = {
      'type': 'updateLocation',
      'lat': lat,
      'lng': lng,
      if (zoom != null) 'zoom': zoom,
    };

    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  void setZoom(double zoom) {
    if (_iframe == null) {
      logger.log('iframe is null, cannot set zoom');
      return;
    }

    if (_iframe!.contentWindow == null) {
      logger.log('iframe contentWindow is null, cannot set zoom');
      return;
    }

    logger.log('Setting zoom: $zoom');
    final message = {'type': 'setZoom', 'zoom': zoom};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    if (_iframe == null || _iframe!.contentWindow == null) {
      return null;
    }

    final completer = Completer<LatLng?>();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    web.EventListener? listenerRef;

    // Set up one-time listener for the response
    final listener =
        ((web.MessageEvent event) {
              final data = event.data;
              try {
                final dataObj = data.dartify() as Map?;
                if (dataObj != null &&
                    dataObj['type'] == 'getCurrentLocationResponse' &&
                    dataObj['requestId'] == requestId) {
                  final lat = (dataObj['lat'] as num).toDouble();
                  final lng = (dataObj['lng'] as num).toDouble();
                  final location = LatLng(lat, lng);
                  logger.log('Got current location: (${location.latitude}, ${location.longitude})');
                  completer.complete(location);
                  if (listenerRef != null) {
                    web.window.removeEventListener('message', listenerRef);
                  }
                }
              } catch (e) {
                logger.error('Error parsing location response', e);
                completer.complete(null);
                if (listenerRef != null) {
                  web.window.removeEventListener('message', listenerRef);
                }
              }
            }).toJS
            as web.EventListener;

    listenerRef = listener;
    web.window.addEventListener('message', listener);

    // Send request
    final message = {'type': 'getCurrentLocation', 'requestId': requestId};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);

    // Timeout after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete(null);
        if (listenerRef != null) {
          web.window.removeEventListener('message', listenerRef);
        }
      }
    });

    return completer.future;
  }

  @override
  Future<double?> getCurrentZoom() async {
    if (_iframe == null || _iframe!.contentWindow == null) {
      return null;
    }

    final completer = Completer<double?>();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    web.EventListener? listenerRef;

    // Set up one-time listener for the response
    final listener =
        ((web.MessageEvent event) {
              final data = event.data;
              try {
                final dataObj = data.dartify() as Map?;
                if (dataObj != null &&
                    dataObj['type'] == 'getCurrentZoomResponse' &&
                    dataObj['requestId'] == requestId) {
                  final zoom = (dataObj['zoom'] as num).toDouble();
                  logger.log('Got current zoom: $zoom');
                  completer.complete(zoom);
                  if (listenerRef != null) {
                    web.window.removeEventListener('message', listenerRef);
                  }
                }
              } catch (e) {
                logger.error('Error parsing zoom response', e);
                completer.complete(null);
                if (listenerRef != null) {
                  web.window.removeEventListener('message', listenerRef);
                }
              }
            }).toJS
            as web.EventListener;

    listenerRef = listener;
    web.window.addEventListener('message', listener);

    // Send request
    final message = {'type': 'getCurrentZoom', 'requestId': requestId};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);

    // Timeout after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete(null);
        if (listenerRef != null) {
          web.window.removeEventListener('message', listenerRef);
        }
      }
    });

    return completer.future;
  }

  @override
  void fitBounds(double north, double south, double east, double west) {
    if (_iframe == null || _iframe!.contentWindow == null) {
      logger.log('iframe is null, cannot fit bounds');
      return;
    }

    logger.log('Fitting bounds: N:$north, S:$south, E:$east, W:$west');
    final message = {
      'type': 'fitBounds',
      'north': north,
      'south': south,
      'east': east,
      'west': west,
    };
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  void addMarker(NeshanMarker marker) {
    if (_iframe == null || _iframe!.contentWindow == null) {
      logger.log('iframe is null, cannot add marker');
      return;
    }

    logger.log('Adding marker: ${marker.id}');
    final message = {'type': 'addMarker', 'marker': marker.toJson()};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  void removeMarker(String markerId) {
    if (_iframe == null || _iframe!.contentWindow == null) {
      logger.log('iframe is null, cannot remove marker');
      return;
    }

    logger.log('Removing marker: $markerId');
    final message = {'type': 'removeMarker', 'markerId': markerId};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  void updateMarkers(List<NeshanMarker> markers) {
    if (_iframe == null || _iframe!.contentWindow == null) {
      logger.log('iframe is null, cannot update markers');
      return;
    }

    logger.log('Updating ${markers.length} markers');
    final message = {
      'type': 'updateMarkers',
      'markers': markers.map((m) => m.toJson()).toList(),
    };
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }

  @override
  void clearMarkers() {
    if (_iframe == null || _iframe!.contentWindow == null) {
      logger.log('iframe is null, cannot clear markers');
      return;
    }

    logger.log('Clearing all markers');
    final message = {'type': 'clearMarkers'};
    _iframe!.contentWindow!.postMessage(message.jsify(), '*'.toJS);
  }
}
