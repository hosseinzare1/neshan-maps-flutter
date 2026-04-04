<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

### Importing the Package

The package provides two separate modules with different purposes:

```dart
// Import only the map module (for map display only)
import 'package:neshan_maps_flutter/map.dart';

// Import the location picker module (includes map functionality)
import 'package:neshan_maps_flutter/location_picker.dart';

// ❌ Incorrect - Don't import internal files
import 'package:neshan_maps_flutter/map/platform/mobile/neshan_map_mobile_widget.dart';
```

**Note**: The location picker module automatically includes the map module, so you don't need to import both separately.

### Examples

#### Using the Map Only

```dart
import 'package:neshan_maps_flutter/map.dart';

final map = NeshanMap(
  mapKey: 'your-api-key',
  config: NeshanMapConfig(
    initialCenter: LatLng(35.6892, 51.3890),
  ),
);
```

#### Using the Location Picker

```dart
import 'package:neshan_maps_flutter/location_picker.dart';

// This import includes both location picker and map functionality
NeshanLocationPicker(
  mapKey: 'your-api-key',
  mapConfig: NeshanMapConfig(
    initialCenter: LatLng(35.6892, 51.3890),
  ),
  onLocationSelected: (location) {
    print('Selected: ${location.address}');
  },
);
```

#### Using Both Explicitly

If you want to be explicit about importing both modules:

```dart
import 'package:neshan_maps_flutter/map.dart';
import 'package:neshan_maps_flutter/location_picker.dart';

// Now you have explicit access to both modules
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
