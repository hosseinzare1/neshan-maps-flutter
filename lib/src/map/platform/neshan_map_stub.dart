import 'package:flutter/material.dart';
import '../../utils/neshan_common.dart';
import '../controller/neshan_map_controller.dart';
import '../config/neshan_map_config.dart';
import '../models/neshan_marker.dart';
import '../../utils/neshan_map_logger.dart';

/// Stub widget for mobile implementation.
///
/// This widget is never used on web since conditional imports route to
/// the actual mobile implementation. It exists only to satisfy the type system.
class NeshanMapMobileWidget extends StatelessWidget {
  const NeshanMapMobileWidget({
    super.key,
    required this.mapKey,
    this.controller,
    this.config,
    this.markers = const [],
    this.onLocationChanged,
    this.onMarkerTapped,
    this.onError,
    this.onLocationError,
    required this.logger,
  });

  final String mapKey;
  final NeshanMapController? controller;
  final NeshanMapConfig? config;
  final List<NeshanMarker> markers;
  final void Function(double lat, double lng)? onLocationChanged;
  final void Function(String markerId)? onMarkerTapped;
  final NeshanErrorCallback? onError;
  final NeshanErrorCallback? onLocationError;
  final NeshanMapLogger logger;

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError(
      'NeshanMapMobileWidget is only available on mobile platforms',
    );
  }
}

/// Stub widget for web implementation.
///
/// This widget is never used on mobile since conditional imports route to
/// the actual web implementation. It exists only to satisfy the type system.
class NeshanMapWebWidget extends StatelessWidget {
  const NeshanMapWebWidget({
    super.key,
    required this.mapKey,
    this.controller,
    this.config,
    this.markers = const [],
    this.onLocationChanged,
    this.onMarkerTapped,
    this.onError,
    this.onLocationError,
    required this.logger,
  });

  final String mapKey;
  final NeshanMapController? controller;
  final NeshanMapConfig? config;
  final List<NeshanMarker> markers;
  final void Function(double lat, double lng)? onLocationChanged;
  final void Function(String markerId)? onMarkerTapped;
  final NeshanErrorCallback? onError;
  final NeshanErrorCallback? onLocationError;
  final NeshanMapLogger logger;

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError(
      'NeshanMapWebWidget is only available on web platform',
    );
  }
}

/// Stub implementation for web platform.
///
/// This function is never called on web since [kIsWeb] check routes to
/// the web implementation first. It exists only to satisfy the type system
/// when compiling for web.
Widget createWebHtmlView({
  required String htmlContent,
  required String mapKey,
  required String iframeId,
  NeshanMapConfig? config,
  List<NeshanMarker> markers = const [],
  NeshanMapController? controller,
  void Function(double lat, double lng)? onLocationChanged,
  void Function(String markerId)? onMarkerTapped,
  NeshanErrorCallback? onError,
  required NeshanMapLogger logger,
  VoidCallback? onDispose,
}) {
  throw UnsupportedError('Web HTML view is only available on web platform');
}

/// Stub function for sending user location to iframe (not supported on mobile)
void sendUserLocationToIframe(String iframeId, double lat, double lng) {
  // This is a stub - the actual implementation is in neshan_map_web.dart
  throw UnsupportedError(
    'sendUserLocationToIframe is only available on web platform',
  );
}

/// Stub function for resetting user location first update flag (not supported on mobile)
void resetUserLocationFirstUpdate(String iframeId) {
  // This is a stub - the actual implementation is in neshan_map_web.dart
  throw UnsupportedError(
    'resetUserLocationFirstUpdate is only available on web platform',
  );
}

/// Stub function for unregistering iframe (not supported on mobile)
void unregisterIframe(String iframeId) {
  // This is a stub - the actual implementation is in neshan_map_web.dart
  throw UnsupportedError('unregisterIframe is only available on web platform');
}

/// Stub types for WebView (only used when compiling for web).
///
/// These classes are never actually instantiated on web since [kIsWeb] check
/// happens first and routes to the web implementation. They exist only to
/// satisfy the type system during compilation.
class JavaScriptMessage {
  final String message;

  JavaScriptMessage({required this.message});
}

class WebViewController {
  WebViewController setJavaScriptMode(dynamic mode) => this;

  WebViewController setBackgroundColor(Color color) => this;

  WebViewController setNavigationDelegate(NavigationDelegate delegate) => this;

  WebViewController loadFlutterAsset(String asset) => this;

  Future<void> loadRequest(Uri uri) async {
    throw UnsupportedError('loadRequest is not available on web platform');
  }

  WebViewController addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage message) onMessageReceived,
  }) => this;

  void runJavaScript(String script) {
    throw UnsupportedError('runJavaScript is not available on web platform');
  }

  Future<Object?> runJavaScriptReturningResult(String script) async {
    throw UnsupportedError(
      'runJavaScriptReturningResult is not available on web platform',
    );
  }
}

class JavaScriptMode {
  static const unrestricted = JavaScriptMode._();

  const JavaScriptMode._();
}

class NavigationDelegate {
  NavigationDelegate({
    void Function(String url)? onPageStarted,
    void Function(String url)? onPageFinished,
    void Function(WebResourceError error)? onWebResourceError,
  });
}

class WebResourceError {
  final String description;

  WebResourceError({required this.description});
}

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;

  const WebViewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError('WebViewWidget is not available on web platform');
  }
}
