import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../utils/neshan_map_logger.dart';
import '../../../utils/neshan_common.dart';
import '../../controller/neshan_map_controller.dart';
import '../../config/neshan_map_config.dart';
import '../../location_tracking/location_tracking_mixin.dart';
import '../../widgets/current_location_button.dart';

/// Mobile implementation of Neshan map using WebView.
///
/// This widget displays the Neshan map in a WebView on mobile platforms
/// (iOS and Android). It handles:
/// - WebView setup and configuration
/// - JavaScript channel communication
/// - Location updates via JavaScript
/// - Marker tap events
class NeshanMapMobileWidget extends StatefulWidget {
  const NeshanMapMobileWidget({
    super.key,
    required this.mapKey,
    this.controller,
    this.config,
    this.onLocationChanged,
    this.onMarkerTapped,
    this.onError,
    this.onLocationError,
    required this.logger,
  });

  final String mapKey;
  final NeshanMapController? controller;
  final NeshanMapConfig? config;
  final void Function(double lat, double lng)? onLocationChanged;
  final void Function(String markerId)? onMarkerTapped;
  final NeshanErrorCallback? onError;
  final NeshanErrorCallback? onLocationError;
  final NeshanMapLogger logger;

  @override
  State<NeshanMapMobileWidget> createState() => _NeshanMapMobileWidgetState();
}

class _NeshanMapMobileWidgetState extends State<NeshanMapMobileWidget>
    with LocationTrackingMixin {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  NeshanMapLogger get logger => widget.logger;

  @override
  NeshanErrorCallback? get onLocationError => widget.onLocationError;

  @override
  void initState() {
    super.initState();
    widget.logger.log('Initializing mobile WebView');
    _controller = _createWebViewController();
    _controller.loadFlutterAsset(neshanMapHtmlAssetPath);
  }

  @override
  void dispose() {
    disposeLocationTracking();
    super.dispose();
  }

  @override
  void sendUserLocationToMap(double lat, double lng) {
    widget.logger.log('Sending user location to map: ($lat, $lng)');
    final script =
        '''
      if (window.updateUserLocation) {
        window.updateUserLocation($lat, $lng);
      }
    ''';
    _controller.runJavaScript(script);
  }

  @override
  void resetUserLocationFirstUpdate() {
    final script = '''
      window.userLocationFirstUpdate = true;
    ''';
    _controller.runJavaScript(script);
  }

  WebViewController _createWebViewController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(_createNavigationDelegate());

    // Always add JavaScript channel for location updates
    controller.addJavaScriptChannel(
      'locationChanged',
      onMessageReceived: _handleLocationMessage,
    );

    // Add JavaScript channel for marker tap events
    controller.addJavaScriptChannel(
      'markerTapped',
      onMessageReceived: _handleMarkerTappedMessage,
    );

    return controller;
  }

  void _handleLocationMessage(JavaScriptMessage message) {
    try {
      // Parse JSON string: {"type":"locationChanged","lat":35.6892,"lng":51.3890}
      final jsonData = jsonDecode(message.message) as Map<String, dynamic>;

      if (jsonData['type'] == 'locationChanged') {
        final lat = (jsonData['lat'] as num).toDouble();
        final lng = (jsonData['lng'] as num).toDouble();

        widget.logger.log('Location changed: ($lat, $lng)');
        widget.onLocationChanged?.call(lat, lng);
      }
    } catch (e, stackTrace) {
      // Always log errors, even when debug is disabled
      final errorMessage = 'Error parsing location message: $e';
      debugPrint('NeshanMap: $errorMessage');
      widget.logger.error('Failed to parse location update', e);
      widget.onError?.call(
        errorMessage,
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  void _handleMarkerTappedMessage(JavaScriptMessage message) {
    try {
      // Parse JSON string: {"type":"markerTapped","markerId":"marker1"}
      final jsonData = jsonDecode(message.message) as Map<String, dynamic>;

      if (jsonData['type'] == 'markerTapped') {
        final markerId = jsonData['markerId'] as String;
        widget.logger.log('Marker tapped: $markerId');
        widget.onMarkerTapped?.call(markerId);
      }
    } catch (e, stackTrace) {
      // Always log errors, even when debug is disabled
      final errorMessage = 'Error parsing marker tapped message: $e';
      debugPrint('NeshanMap: $errorMessage');
      widget.logger.error('Failed to parse marker tap', e);
      widget.onError?.call(
        errorMessage,
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      onPageStarted: (_) => _handlePageStarted(),
      onPageFinished: (_) => _handlePageFinished(),
      onWebResourceError: _handleWebResourceError,
    );
  }

  void _handlePageStarted() {
    if (mounted) {
      setState(() => _isLoading = true);
    }
  }

  void _handlePageFinished() {
    if (mounted) {
      setState(() => _isLoading = false);
      widget.logger.log('WebView page finished loading');
      // Inject configuration immediately after page loads
      // SDK is now bundled locally for instant availability
      if (mounted) {
        _injectConfiguration();
        // Register controller with WebViewController after page loads
        if (widget.controller != null) {
          widget.logger.log('Registering controller with WebViewController');
          widget.controller!.setLogger(widget.logger);
          widget.controller!.setWebViewController(_controller);
        } else {
          widget.logger.log('No controller provided');
        }
      }
    }
  }

  void _injectConfiguration() {
    final config = widget.config ?? const NeshanMapConfig();
    final markersJson = jsonEncode(
      config.markers.map((m) => m.toJson()).toList(),
    );
    widget.logger.log(
      'Injecting configuration - center: (${config.initialCenter.latitude}, ${config.initialCenter.longitude}), '
      'zoom: ${config.initialZoom}, markers: ${config.markers.length}',
    );
    final script =
        '''
      (function() {
        window.neshanMapConfig = {
          mapKey: "${widget.mapKey}",
          mapType: "${config.mapType.value}",
          center: [${config.initialCenter.longitude}, ${config.initialCenter.latitude}],
          zoom: ${config.initialZoom},
          minZoom: ${config.minZoom},
          maxZoom: ${config.maxZoom},
          poi: ${config.showPoi},
          traffic: ${config.showTraffic},
          markers: $markersJson
        };
        // SDK is bundled locally, so initializeMap should be immediately available
        if (typeof initializeMap === 'function') {
          initializeMap();
        } else {
          console.error('NeshanMap: initializeMap function not found - SDK may not be loaded properly');
        }
      })();
    ''';
    try {
      _controller.runJavaScript(script);
    } catch (error, stackTrace) {
      widget.logger.error('Error injecting configuration', error);
      widget.onError?.call(
        'Failed to inject map configuration',
        error is Exception ? error : Exception(error.toString()),
        stackTrace,
      );
    }
  }

  void _handleWebResourceError(WebResourceError error) {
    // Always log errors, even when debug is disabled
    final errorMessage = 'WebView error: ${error.description}';
    debugPrint('NeshanMap: $errorMessage');
    widget.logger.error('WebView resource error', error.description);
    widget.onError?.call(error.description, Exception(error.description), null);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const NeshanMapConfig();
    final showButton = config.showCurrentLocationButton;

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
        // Only show button after map has loaded
        if (showButton && !_isLoading)
          CurrentLocationButton(
            isTracking: isTrackingLocation,
            onTap: handleCurrentLocationTap,
          ),
      ],
    );
  }
}
