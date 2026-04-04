import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../../../utils/neshan_common.dart';
import '../../controller/neshan_map_controller.dart';
import '../../config/neshan_map_config.dart';
import '../../../utils/neshan_map_logger.dart';

/// Global map of iframe references by unique ID for location updates
final Map<String, web.HTMLIFrameElement> _iframeReferences = {};

/// Sends user location update to a specific iframe
void sendUserLocationToIframe(String iframeId, double lat, double lng) {
  final iframe = _iframeReferences[iframeId];
  if (iframe == null) return;

  final message = {'type': 'updateUserLocation', 'lat': lat, 'lng': lng};
  iframe.contentWindow?.postMessage(message.jsify(), '*'.toJS);
}

/// Resets the user location first update flag in a specific iframe
void resetUserLocationFirstUpdate(String iframeId) {
  final iframe = _iframeReferences[iframeId];
  if (iframe == null) return;

  final message = {'type': 'resetUserLocationFirstUpdate'};
  iframe.contentWindow?.postMessage(message.jsify(), '*'.toJS);
}

/// Registers an iframe with a unique ID
void _registerIframe(String iframeId, web.HTMLIFrameElement iframe) {
  _iframeReferences[iframeId] = iframe;
}

/// Unregisters an iframe when it's disposed
void unregisterIframe(String iframeId) {
  _iframeReferences.remove(iframeId);
}

/// Creates a web view widget that displays HTML content in an iframe.
///
/// This function creates an iframe element with the [htmlContent] as its
/// source using the `srcdoc` attribute, which allows inline HTML and properly
/// loads external resources (CSS, JavaScript).
///
/// The iframe is registered with Flutter's platform view registry and returned
/// as an [HtmlElementView] widget.
///
/// A postMessage listener is always set up to receive location updates from
/// the iframe, and [onLocationChanged] will be called when the map center changes.
///
/// If [controller] is provided, it will be registered with the iframe to allow
/// programmatic map control.
///
/// [onMarkerTapped] callback is called when a marker is tapped.
/// Provides the ID of the tapped marker.
///
/// [onError] callback is called when an error occurs (e.g., iframe load errors,
/// JSON parsing errors).
///
/// [iframeId] is a unique identifier for this iframe instance, used for location tracking.
///
/// [logger] is used for debug logging throughout the web implementation.
///
/// [onDispose] is called when the iframe should be cleaned up.
Widget createWebHtmlView({
  required String htmlContent,
  required String mapKey,
  required String iframeId,
  NeshanMapConfig? config,
  NeshanMapController? controller,
  void Function(double lat, double lng)? onLocationChanged,
  void Function(String markerId)? onMarkerTapped,
  NeshanErrorCallback? onError,
  required NeshanMapLogger logger,
  VoidCallback? onDispose,
}) {
  final String viewId = _generateUniqueViewId();
  final web.HTMLIFrameElement iframe = _createIframe(
    htmlContent,
    mapKey,
    config,
    onError,
    logger,
  );

  // Register controller with iframe
  if (controller != null) {
    logger.log('Registering controller with iframe');
    controller.setLogger(logger);
    controller.setIframe(iframe);
  } else {
    logger.log('No controller provided');
  }

  // Store iframe reference with unique ID for location updates
  _registerIframe(iframeId, iframe);

  // Always set up postMessage listener for location updates and marker taps
  // Use addEventListener instead of direct assignment to avoid overwriting other listeners
  final messageListener = ((web.MessageEvent event) {
    final data = event.data;
    try {
      // Convert JSAny to Dart Map
      final dataObj = data.dartify() as Map?;
      if (dataObj != null && dataObj['type'] == 'locationChanged') {
        final lat = (dataObj['lat'] as num).toDouble();
        final lng = (dataObj['lng'] as num).toDouble();
        logger.log('Location changed (web): ($lat, $lng)');
        onLocationChanged?.call(lat, lng);
      } else if (dataObj != null && dataObj['type'] == 'markerTapped') {
        final markerId = dataObj['markerId'] as String;
        logger.log('Marker tapped (web): $markerId');
        onMarkerTapped?.call(markerId);
      }
    } catch (e, stackTrace) {
      // Always log errors, even when debug is disabled
      final errorMessage = 'Error parsing message data: $e';
      debugPrint('NeshanMap: $errorMessage');
      logger.error('Failed to parse message', e);
      onError?.call(
        errorMessage,
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }).toJS;

  web.window.addEventListener('message', messageListener);

  ui_web.platformViewRegistry.registerViewFactory(viewId, (_) => iframe);

  return HtmlElementView(viewType: viewId);
}

/// Generates a unique view ID for the platform view registry.
String _generateUniqueViewId() {
  return 'neshan-map-${DateTime.now().millisecondsSinceEpoch}';
}

/// Creates and configures an iframe element with the provided HTML content.
web.HTMLIFrameElement _createIframe(
  String htmlContent,
  String mapKey,
  NeshanMapConfig? config,
  NeshanErrorCallback? onError,
  NeshanMapLogger logger,
) {
  final iframe = web.HTMLIFrameElement()
    ..srcdoc = htmlContent.toJS
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.margin = '0'
    ..style.padding = '0';

  // Wait for iframe to load before it can receive messages
  iframe.addEventListener(
    'load',
    ((web.Event _) {
      logger.log('Iframe loaded and ready');
      // Inject configuration after iframe loads
      _injectConfigurationToIframe(iframe, mapKey, config, logger);
    }).toJS,
  );

  // Handle iframe load errors
  iframe.addEventListener(
    'error',
    ((web.Event _) {
      final errorMessage = 'Failed to load map iframe';
      debugPrint('NeshanMap: $errorMessage');
      logger.error('Iframe loading error', null);
      onError?.call('Map loading error', Exception(errorMessage), null);
    }).toJS,
  );

  return iframe;
}

void _injectConfigurationToIframe(
  web.HTMLIFrameElement iframe,
  String mapKey,
  NeshanMapConfig? config,
  NeshanMapLogger logger,
) {
  final configObj = config ?? const NeshanMapConfig();

  logger.log(
    'Injecting configuration - center: (${configObj.initialCenter.latitude}, ${configObj.initialCenter.longitude}), '
    'zoom: ${configObj.initialZoom}, markers: ${configObj.markers.length}',
  );

  // Use postMessage to send configuration to iframe
  // Since iframe uses srcdoc, it's same-origin and can receive messages
  final message = {
    'type': 'initializeMap',
    'config': {
      'mapKey': mapKey,
      'mapType': configObj.mapType.value,
      'center': [
        configObj.initialCenter.longitude,
        configObj.initialCenter.latitude,
      ],
      'zoom': configObj.initialZoom,
      'minZoom': configObj.minZoom,
      'maxZoom': configObj.maxZoom,
      'poi': configObj.showPoi,
      'traffic': configObj.showTraffic,
      'markers': configObj.markers.map((m) => m.toJson()).toList(),
    },
  };

  // SDK is now bundled locally, send config immediately
  // A small delay ensures the iframe's window is ready to receive messages
  Future.delayed(const Duration(milliseconds: 50), () {
    iframe.contentWindow?.postMessage(message.jsify(), '*'.toJS);
  });
}
