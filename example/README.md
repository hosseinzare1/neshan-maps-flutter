# Example: `neshan_maps_flutter`

Sample app that exercises **NeshanMap** and **NeshanLocationPicker** from the parent package (`../`).

## Setup

1. Open `lib/api_keys.dart` and set your Neshan keys from [platform.neshan.org](https://platform.neshan.org/). The map key must be a **Web** key. Treat keys like secrets; the placeholders are for local testing only.

2. From this directory:

   ```sh
   flutter pub get
   flutter run
   ```

## What’s inside

- **Home** — buttons to open the map demo and the location picker demo.
- **Map** — map with a marker and an app bar action to jump to the Milad Tower area.
- **Location picker** — full picker flow; confirming shows the chosen point in a snack bar.

Android and iOS include the [geolocator](https://pub.dev/packages/geolocator) permission setup needed when the map’s “current location” UI is used. For full package docs, see the repository root `README.md`.
