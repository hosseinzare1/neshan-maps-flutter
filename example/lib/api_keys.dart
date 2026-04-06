// **Security:** Do not hardcode API keys in production apps.
//
// Keys in source code can be extracted from the app binary or repository.
// Prefer loading secrets at runtime (for example from your own backend,
// `--dart-define`, or a secure store), and never commit real keys.
//
// This file exists only so the example can run locally after you paste keys
// for testing. The placeholders below are empty by default.

/// Neshan map key — must be a **Web** key. See [platform.neshan.org](https://platform.neshan.org/).
const String kMapKey = '';

/// Reverse geocoding API key (location picker address bar).
const String kReverseGeocodingApiKey = '';

/// Search API key (optional; location picker search). Leave empty to disable search.
const String kSearchApiKey = '';
