import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/neshan_map_logger.dart';
import '../../../utils/neshan_common.dart';
import '../../controller/neshan_map_controller.dart';
import '../../config/neshan_map_config.dart';
import '../../models/neshan_marker.dart';
import 'neshan_map_web.dart'
    if (dart.library.io) 'neshan_map_stub.dart'
    as web_impl;
import '../../location_tracking/location_tracking_mixin.dart';
import '../../widgets/current_location_button.dart';

/// Web implementation of Neshan map using iframe.
///
/// This widget displays the Neshan map in an iframe on web platforms.
/// It handles:
/// - HTML asset loading
/// - Iframe creation and caching
/// - PostMessage communication
/// - Location updates via postMessage
/// - Marker tap events
class NeshanMapWebWidget extends StatefulWidget {
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
  State<NeshanMapWebWidget> createState() => _NeshanMapWebWidgetState();
}

class _NeshanMapWebWidgetState extends State<NeshanMapWebWidget>
    with LocationTrackingMixin {
  static const String _defaultErrorMessage = 'Failed to load map';

  late final String _iframeId; // Unique ID for this map instance
  String? _htmlContent;
  bool _isLoading = true;
  String? _errorMessage;
  Widget? _cachedWebView; // Cache the web view to prevent recreation

  @override
  NeshanMapLogger get logger => widget.logger;

  @override
  NeshanErrorCallback? get onLocationError => widget.onLocationError;

  @override
  void initState() {
    super.initState();
    _iframeId = 'neshan_map_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    widget.logger.log('Initializing web iframe with ID: $_iframeId');
    _loadHtml();
  }

  @override
  void dispose() {
    disposeLocationTracking();
    // Unregister iframe on web to prevent cross-instance interference
    if (kIsWeb) {
      web_impl.unregisterIframe(_iframeId);
    }
    super.dispose();
  }

  @override
  void sendUserLocationToMap(double lat, double lng) {
    widget.logger.log('Sending user location to iframe: ($lat, $lng)');
    // Call the global function from web_impl with this instance's iframe ID
    web_impl.sendUserLocationToIframe(_iframeId, lat, lng);
  }

  @override
  void resetUserLocationFirstUpdate() {
    // Call the global function from web_impl with this instance's iframe ID
    web_impl.resetUserLocationFirstUpdate(_iframeId);
  }

  Future<void> _loadHtml() async {
    try {
      widget.logger.log('Loading HTML asset from: $neshanMapHtmlAssetPath');
      final htmlTemplate = await rootBundle.loadString(neshanMapHtmlAssetPath);
      if (mounted) {
        widget.logger.log('HTML asset loaded successfully');
        setState(() {
          _htmlContent = htmlTemplate;
          _isLoading = false;
          _errorMessage = null;
        });
        // Create the web view once and cache it
        _createCachedWebView();
      }
    } catch (e, stackTrace) {
      // Always log errors, even when debug is disabled
      final errorMessage = 'Error loading HTML asset: $e';
      debugPrint('NeshanMap: $errorMessage');
      widget.logger.error('Failed to load HTML asset', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _defaultErrorMessage;
        });
        widget.onError?.call(
          'Failed to load map',
          e is Exception ? e : Exception(e.toString()),
          stackTrace,
        );
      }
    }
  }

  void _createCachedWebView() {
    if (_htmlContent == null) return;

    widget.logger.log('Creating web HTML view');
    _cachedWebView = web_impl.createWebHtmlView(
      htmlContent: _htmlContent!,
      mapKey: widget.mapKey,
      iframeId: _iframeId,
      config: widget.config,
      markers: widget.markers,
      controller: widget.controller,
      onLocationChanged: widget.onLocationChanged,
      onMarkerTapped: widget.onMarkerTapped,
      onError: widget.onError,
      logger: widget.logger,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cachedWebView == null) {
      return Center(child: Text(_errorMessage ?? _defaultErrorMessage));
    }

    final config = widget.config ?? const NeshanMapConfig();
    final showButton = config.showCurrentLocationButton;

    if (!showButton) {
      // Use the cached web view to prevent recreation on setState
      return _cachedWebView!;
    }

    // Use the cached web view with button overlay
    return Stack(
      children: [
        _cachedWebView!,
        CurrentLocationButton(
          isTracking: isTrackingLocation,
          onTap: handleCurrentLocationTap,
        ),
      ],
    );
  }
}
