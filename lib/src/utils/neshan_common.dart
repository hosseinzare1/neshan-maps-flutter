// ============ Constants ============

/// Path to the HTML asset file for the Neshan map.
const String neshanMapHtmlAssetPath =
    'packages/neshan_maps_flutter/assets/html/neshan-map.html';

// ============ Error Callback ============

/// Callback that is called when an error occurs.
///
/// [message] is the error message.
/// [exception] is the optional exception that caused the error.
/// [stackTrace] is the optional stack trace for debugging.
typedef NeshanErrorCallback =
    void Function(String message, Exception? exception, StackTrace? stackTrace);
