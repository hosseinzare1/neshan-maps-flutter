import 'neshan_map_controller_base.dart';

// On web, import the web implementation
// On mobile, this will be a stub import
import 'neshan_map_controller_web.dart'
    if (dart.library.io) 'neshan_map_controller_stub.dart'
    as web_impl;

/// Stub for WebViewController when compiling for web.
class WebViewController {
  void runJavaScript(String script) {
    throw UnsupportedError(
      'WebViewController is not available on web platform',
    );
  }
}

/// Stub for web.HTMLIFrameElement when compiling for mobile.
class HTMLIFrameElement {
  dynamic get contentWindow => throw UnsupportedError(
    'HTMLIFrameElement is not available on mobile platform',
  );
}

/// Creates the appropriate controller implementation.
///
/// On web, this delegates to the web implementation.
/// On mobile, this throws an error (should not be called).
NeshanMapControllerImpl createController() {
  // On web, this will call the web implementation
  // On mobile, this will throw (but shouldn't be called since impl is used)
  return web_impl.createWebController();
}

/// Creates the web controller implementation (stub for mobile).
NeshanMapControllerImpl createWebController() {
  throw UnsupportedError('Web controller not available on mobile platform');
}
