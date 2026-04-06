# Neshan Maps Flutter

A Flutter SDK for integrating [Neshan Maps](https://platform.neshan.org/) into your Flutter applications.

## Features

- **Cross-platform** — works on Android, iOS, Web, and all other Flutter-supported platforms
- **Interactive Map** — pan, zoom, multiple map styles, traffic layer, and POI toggles
- **Markers & Controller** — place markers declaratively or manage them at runtime via `NeshanMapController`
- **Location Picker** — draggable centre-pin with automatic reverse-geocoding and built-in place search
- **Customisable UI** — override the address bar, confirm button, and centre marker with your own widgets

---

## Table of Contents

- [Getting API Keys](#getting-api-keys)
- [Installation](#installation)
- [Location Permission Setup](#location-permission-setup)
- [Screenshots](#screenshots)
- [Quick Start](#quick-start)
- [NeshanMap — Full Reference](#neshanmap--full-reference)
- [NeshanLocationPicker — Full Reference](#neshanlocationpicker--full-reference)
- [Imports](#imports)
- [Contributing](#contributing)
- [License](#license)

---

## Getting API Keys

Register at **[platform.neshan.org](https://platform.neshan.org/)** and create the following keys:


| Key                      | Used for                                                             |
| ------------------------ | -------------------------------------------------------------------- |
| `mapKey`                 | Displaying the map — required for both widgets                       |
| `reverseGeocodingApiKey` | Converting coordinates to an address string (`NeshanLocationPicker`) |
| `searchApiKey`           | Searching for places by name (`NeshanLocationPicker`)                |


### Important notes

**The `mapKey` must be a Web key.**
This package renders the Neshan map using the Neshan Web SDK on all platforms (via a WebView on mobile and an `<iframe>` on web). When creating the key in the Neshan dashboard, select **Web** as the platform — an Android or iOS key will not work.

**Do not restrict the allowed domain / IP.**
Because requests originate from a WebView (on device) rather than a known server domain, setting an allowed-domain or IP restriction on the key will cause map loading to fail. Leave this field unrestricted.

**Keep keys out of your source code.**
Never commit API keys to version control. A recommended approach is to serve the keys from your own backend API and fetch them at runtime, so they are never bundled inside the app binary.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  neshan_maps_flutter: ^1.0.0
```

Then run:

```sh
flutter pub get
```

---

## Location Permission Setup

> **This step is optional.** It is only required if you want to show the user's current location on the map via `showCurrentLocationButton: true` in `NeshanMapConfig` (the default).  
> If you set `showCurrentLocationButton: false`, you can skip this section entirely.

This package uses the [geolocator](https://pub.dev/packages/geolocator) plugin internally to access device location. Follow the **platform-specific permission instructions** in the [geolocator documentation](https://pub.dev/packages/geolocator#usage) to add the required entries to your `AndroidManifest.xml`, `Info.plist`, and any other platform files.

---

## Screenshots

| NeshanMap | NeshanLocationPicker | Location Search |
|:---------:|:--------------------:|:---------------:|
| ![Map](https://raw.githubusercontent.com/hosseinzare1/neshan-maps-flutter/main/screenshots/map.png) | ![Picker](https://raw.githubusercontent.com/hosseinzare1/neshan-maps-flutter/main/screenshots/picker.png) | ![Search](https://raw.githubusercontent.com/hosseinzare1/neshan-maps-flutter/main/screenshots/search.png) |


---

## Quick Start

### NeshanMap — minimal usage

```dart
import 'package:neshan_maps_flutter/map.dart';

NeshanMap(
  mapKey: 'YOUR_MAP_KEY',
)
```

That's it. The map opens at the default location and zoom level.

### NeshanLocationPicker — minimal usage

```dart
import 'package:neshan_maps_flutter/location_picker.dart';

NeshanLocationPicker(
  mapKey: 'YOUR_MAP_KEY',
  reverseGeocodingApiKey: 'YOUR_REVERSE_GEOCODING_KEY',
  onLocationAccepted: (position, address) {
    print('Selected: $address at ${position.latitude}, ${position.longitude}');
  },
)
```

As the user pans, the address bar at the top updates automatically. Tapping the confirm button triggers `onLocationAccepted`.

---

## NeshanMap — Full Reference

`NeshanMap` is a cross-platform widget that renders an interactive Neshan map. On mobile it uses a `WebView`; on web it uses an `<iframe>`.

### Overlays on web

On **web**, the map sits in an `HtmlElementView` behind your Flutter widgets. Overlays such as buttons, sheets, or the location FAB may not receive taps—the underlying map can consume pointer events first. Wrap interactive overlays with `PointerInterceptor` from [pointer_interceptor](https://pub.dev/packages/pointer_interceptor) — add that package to your app’s `pubspec.yaml` so you can import it. See the [package README](https://pub.dev/packages/pointer_interceptor) for usage, including the `intercepting` flag when interception is only needed sometimes.

### Complete example

```dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neshan_maps_flutter/map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _controller = NeshanMapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeshanMap(
        mapKey: 'YOUR_MAP_KEY',
        controller: _controller,
        config: NeshanMapConfig(
          initialCenter: LatLng(35.6892, 51.3890),
          initialZoom: 14.0,
          mapType: NeshanMapType.neshanVector,
          showTraffic: true,
        ),
        markers: const [
          NeshanMarker(
            id: 'hq',
            position: LatLng(35.6892, 51.3890),
            title: 'HQ',
            color: Colors.red,
          ),
        ],
        onLocationChanged: (lat, lng) {
          debugPrint('Centre moved to $lat, $lng');
        },
        onMarkerTapped: (markerId) {
          debugPrint('Marker tapped: $markerId');
        },
        onError: (message, details) {
          debugPrint('Map error: $message');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _controller.ready;
          _controller.moveToLocation(35.7448, 51.3753, zoom: 15);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
```

### NeshanMap Parameters


| Parameter           | Type                                     | Required | Default | Description                                                                    |
| ------------------- | ---------------------------------------- | -------- | ------- | ------------------------------------------------------------------------------ |
| `mapKey`            | `String`                                 | ✅        | —       | Neshan API key. Obtain at [platform.neshan.org](https://platform.neshan.org/). |
| `config`            | `NeshanMapConfig?`                       |          | zoom 12 | Viewport and style configuration.                                              |
| `markers`           | `List<NeshanMarker>`                     |          | `[]`    | Initial markers placed when the map loads.                                     |
| `controller`        | `NeshanMapController?`                   |          | —       | Programmatic control: pan, zoom, add/remove markers.                           |
| `onLocationChanged` | `void Function(double lat, double lng)?` |          | —       | Fired when the map centre changes.                                             |
| `onMarkerTapped`    | `void Function(String markerId)?`        |          | —       | Fired when a marker is tapped; receives the marker ID.                         |
| `onError`           | `NeshanErrorCallback?`                   |          | —       | Fired on WebView / iframe / parsing errors.                                    |
| `onLocationError`   | `NeshanErrorCallback?`                   |          | —       | Fired on location permission or service errors.                                |
| `enableDebug`       | `bool`                                   |          | `false` | Enables verbose console logging.                                               |


---

### NeshanMapConfig

Controls the initial viewport and style of the map. All parameters are optional.

```dart
NeshanMapConfig(
  initialCenter: LatLng(35.6892, 51.3890), // Default initial center
  initialZoom: 14.0,                        // Default: 12.0
  mapType: NeshanMapType.neshanVectorNight, // Default: neshanVector
  minZoom: 5.0,                             // Default: 2.0
  maxZoom: 18.0,                            // Default: 21.0
  showPoi: false,                           // Default: true
  showTraffic: true,                        // Default: false
  showCurrentLocationButton: false,         // Default: true
)
```


| Parameter                   | Type            | Default                    | Description                                                  |
| --------------------------- | --------------- | -------------------------- | ------------------------------------------------------------ |
| `initialCenter`             | `LatLng`        | `LatLng(35.6892, 51.3890)` | Starting map centre coordinate.                              |
| `initialZoom`               | `double`        | `12.0`                     | Starting zoom level.                                         |
| `mapType`                   | `NeshanMapType` | `neshanVector`             | Map style (see below).                                       |
| `minZoom`                   | `double`        | `2.0`                      | Minimum zoom the user can reach.                             |
| `maxZoom`                   | `double`        | `21.0`                     | Maximum zoom the user can reach.                             |
| `showPoi`                   | `bool`          | `true`                     | Whether to render points of interest.                        |
| `showTraffic`               | `bool`          | `false`                    | Whether to render the traffic layer.                         |
| `showCurrentLocationButton` | `bool`          | `true`                     | Shows a FAB that centres the map on the user's GPS position. |


#### NeshanMapType


| Value                             | Description              |
| --------------------------------- | ------------------------ |
| `NeshanMapType.neshanVector`      | Default vector map       |
| `NeshanMapType.neshanVectorNight` | Vector map in night mode |
| `NeshanMapType.neshanRaster`      | Raster (tile) map        |
| `NeshanMapType.neshanRasterNight` | Raster map in night mode |


---

### NeshanMarker

Represents a pin on the map.

```dart
NeshanMarker(
  id: 'office',              // Required — unique identifier
  position: LatLng(35.6892, 51.3890), // Required
  color: Colors.deepPurple, // Optional — defaults to Neshan blue
  title: 'Our Office',      // Optional — popup text when tapped
  draggable: false,          // Optional — default false
)
```


| Parameter   | Type      | Required | Description                                                        |
| ----------- | --------- | -------- | ------------------------------------------------------------------ |
| `id`        | `String`  | ✅        | Unique marker identifier (used to reference it in the controller). |
| `position`  | `LatLng`  | ✅        | Geographic coordinates.                                            |
| `color`     | `Color?`  |          | Marker colour. Any Flutter `Color` value.                          |
| `title`     | `String?` |          | Text shown in a popup when the marker is tapped.                   |
| `draggable` | `bool`    |          | Whether the user can drag the marker. Default `false`.             |


---

### NeshanMapController

Use `NeshanMapController` to control the map programmatically after it has loaded.

> **Important:** Always `await controller.ready` before calling any method to ensure the map is fully initialised.

```dart
final controller = NeshanMapController();

// Pass to NeshanMap, then:
await controller.ready;

// Move camera
controller.moveToLocation(35.6892, 51.3890, zoom: 15.0);

// Change zoom only
controller.setZoom(12.0);

// Fit to bounding box (north, south, east, west)
controller.fitBounds(36.0, 35.0, 52.0, 51.0);

// Query state
final center = await controller.getCurrentLocation();
final zoom   = await controller.getCurrentZoom();

// Manage markers
controller.addMarker(NeshanMarker(id: 'new', position: LatLng(35.7, 51.4)));
controller.removeMarker('new');
controller.updateMarkers([/* replacement list */]);
controller.clearMarkers();

// Cleanup
controller.dispose();
```


| Method                                | Returns           | Description                                            |
| ------------------------------------- | ----------------- | ------------------------------------------------------ |
| `moveToLocation(lat, lng, {zoom})`    | `void`            | Animates the camera to the given coordinates.          |
| `setZoom(zoom)`                       | `void`            | Animates to the given zoom level.                      |
| `fitBounds(north, south, east, west)` | `void`            | Fits the viewport to a bounding box.                   |
| `getCurrentLocation()`                | `Future<LatLng?>` | Returns the current map centre.                        |
| `getCurrentZoom()`                    | `Future<double?>` | Returns the current zoom level.                        |
| `addMarker(marker)`                   | `void`            | Adds a single marker at runtime.                       |
| `removeMarker(markerId)`              | `void`            | Removes a marker by ID.                                |
| `updateMarkers(markers)`              | `void`            | Replaces all markers with a new list.                  |
| `clearMarkers()`                      | `void`            | Removes all markers.                                   |
| `dispose()`                           | `void`            | Releases resources. Call in your widget's `dispose()`. |


---

## NeshanLocationPicker — Full Reference

> The picker is ready to use out of the box — no extra configuration is needed beyond the API keys.  
> For deeper understanding of the underlying APIs, refer to the official Neshan documentation:
>
> - Reverse Geocoding API: [platform.neshan.org/docs/api/search-category/reverse-geocoding](https://platform.neshan.org/docs/api/search-category/reverse-geocoding/)
> - Search API: [platform.neshan.org/docs/api/search-category/search](https://platform.neshan.org/docs/api/search-category/search/)

`NeshanLocationPicker` wraps `NeshanMap` and adds:

- A **centre-pin overlay** indicating the selected location.
- An **address bar** at the top that updates via reverse-geocoding as the user pans.
- A **search button** (when `searchApiKey` is provided) that opens a full-screen search UI.
- A **confirm button** that calls `onLocationAccepted` with the final `LatLng` and address string.

### Complete example

```dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neshan_maps_flutter/location_picker.dart';

class PickerPage extends StatelessWidget {
  const PickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeshanLocationPicker(
        mapKey: 'YOUR_MAP_KEY',
        reverseGeocodingApiKey: 'YOUR_REVERSE_GEOCODING_KEY',
        searchApiKey: 'YOUR_SEARCH_KEY', // Optional — enables search
        mapConfig: NeshanMapConfig(
          initialCenter: LatLng(35.6892, 51.3890),
          initialZoom: 14.0,
        ),
        locationPickerConfig: NeshanLocationPickerConfig(
          geocodingDebounce: Duration(milliseconds: 400),
          searchDebounce: Duration(milliseconds: 400),
        ),
        onLocationAccepted: (position, address) {
          Navigator.pop(context);
          print('Picked: $address (${position.latitude}, ${position.longitude})');
        },
        onAddressChanged: (address, response) {
          debugPrint('Address: $address | City: ${response.city}');
        },
        onApiError: (error) {
          debugPrint('API error [${error.statusCode}]: ${error.message}');
        },
      ),
    );
  }
}
```

### NeshanLocationPicker Parameters


| Parameter                | Type                                               | Required | Description                                                                                                      |
| ------------------------ | -------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------- |
| `mapKey`                 | `String`                                           | ✅        | Neshan map API key.                                                                                              |
| `reverseGeocodingApiKey` | `String`                                           | ✅        | Neshan reverse-geocoding API key. Enables the address bar.                                                       |
| `onLocationAccepted`     | `void Function(LatLng, String)`                    | ✅        | Called when the user confirms the selection. Receives the `LatLng` position and formatted address string.        |
| `mapConfig`              | `NeshanMapConfig?`                                 |          | Viewport and style of the underlying map.                                                                        |
| `markers`                | `List<NeshanMarker>`                               |          | Static markers shown alongside the centre-pin overlay.                                                           |
| `controller`             | `NeshanMapController?`                             |          | External controller for programmatic map control. An internal one is created automatically if omitted.           |
| `searchApiKey`           | `String?`                                          |          | Neshan search API key. **When provided**, a search icon appears in the address bar. Omitting it disables search. |
| `locationPickerConfig`   | `NeshanLocationPickerConfig?`                      |          | Debounce durations for geocoding and search.                                                                     |
| `uiConfig`               | `LocationPickerUiConfig?`                          |          | Custom builders for the address bar, confirm button, and centre marker.                                          |
| `onLocationChanged`      | `void Function(double lat, double lng)?`           |          | Fired when the map centre changes.                                                                               |
| `onAddressChanged`       | `void Function(String, ReverseGeocodingResponse)?` |          | Fired when reverse-geocoding returns a new address.                                                              |
| `onApiError`             | `void Function(NeshanApiError)?`                   |          | Fired when a geocoding or search API request fails.                                                              |
| `onError`                | `NeshanErrorCallback?`                             |          | Fired on general (non-API) errors.                                                                               |
| `enableDebug`            | `bool`                                             |          | Verbose console logging. Default `false`.                                                                        |


---

### NeshanLocationPickerConfig

Controls how aggressively the widget calls the Neshan APIs.

```dart
NeshanLocationPickerConfig(
  geocodingDebounce: Duration(milliseconds: 500), // Default: 300 ms
  searchDebounce: Duration(milliseconds: 400),    // Default: 300 ms
)
```


| Parameter           | Type       | Default | Description                                                                           |
| ------------------- | ---------- | ------- | ------------------------------------------------------------------------------------- |
| `geocodingDebounce` | `Duration` | 300 ms  | How long to wait after the map stops moving before calling the reverse-geocoding API. |
| `searchDebounce`    | `Duration` | 300 ms  | How long to wait after the user stops typing before calling the search API.           |


---

### LocationPickerUiConfig — UI customization

Override any of the three overlay widgets with your own builders. Omitting a builder falls back to the default implementation.

```dart
NeshanLocationPicker(
  mapKey: 'YOUR_MAP_KEY',
  reverseGeocodingApiKey: 'YOUR_REVERSE_GEOCODING_KEY',
  onLocationAccepted: (position, address) { /* ... */ },
  uiConfig: LocationPickerUiConfig(
    // Custom address bar
    addressDisplayBuilder: (context, data) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),
        child: data.isLoading
            ? const LinearProgressIndicator()
            : Text(data.formattedAddress ?? 'Move the map to select a location'),
      );
    },

    // Custom confirm button
    acceptButtonBuilder: (context, data) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: data.onPressed,
          icon: const Icon(Icons.check),
          label: Text(data.isEnabled ? 'Confirm' : 'Loading…'),
        ),
      );
    },

    // Custom centre pin
    centerMarkerBuilder: (context) {
      return const Icon(Icons.location_pin, size: 48, color: Colors.red);
    },
  ),
)
```

#### AddressDisplayData

Provided to `addressDisplayBuilder`:


| Field              | Type                        | Description                                                                  |
| ------------------ | --------------------------- | ---------------------------------------------------------------------------- |
| `formattedAddress` | `String?`                   | Human-readable address string from reverse-geocoding.                        |
| `fullResponse`     | `ReverseGeocodingResponse?` | Full API response with city, state, neighbourhood, traffic zone flags, etc.  |
| `isLoading`        | `bool`                      | `true` while a geocoding request is in flight.                               |
| `hasError`         | `bool`                      | `true` if the last geocoding request failed.                                 |
| `isSearchEnabled`  | `bool`                      | `true` when a `searchApiKey` has been supplied.                              |
| `openSearchScreen` | `VoidCallback?`             | Call this to open the search screen; `null` when search is disabled.         |


#### AcceptButtonData

Provided to `acceptButtonBuilder`:


| Field             | Type            | Description                                                                   |
| ----------------- | --------------- | ----------------------------------------------------------------------------- |
| `onPressed`       | `VoidCallback?` | Call in your button's `onPressed`. `null` when the button should be disabled. |
| `isEnabled`       | `bool`          | Whether the button should be active.                                          |
| `currentLocation` | `LatLng?`       | The currently selected coordinates.                                           |
| `currentAddress`  | `String?`       | The currently resolved address string.                                        |

---

## **Contributions**

Contributions are welcome! If you have suggestions for improvements, feature requests, or bug fixes, feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/hosseinzare1/neshan-maps-flutter).

---

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.