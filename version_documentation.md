# Version Documentation

## ver 1.0.2
- **Date**: 13 November 2026
- **Status**: Production Release Update
- **Author/Manager**: Shoyeb Ahammed
- **Summary**:
  - **Proper World Map Integration**: Replaced vector approximations with real global cartography powered by `flutter_map` (v8.3.2) and `latlong2`.
  - **Tile Providers**: Integrated high-performance CartoDB Dark Matter tiles (`https://{s}.basemaps.cartocdn.com/dark_all/...`) for cockpit dark mode, CartoDB Voyager for light mode, and ArcGIS World Imagery for satellite view toggle.
  - **Flight Route Visualization**: Real Great-Circle geodesic trajectory polyline with 50-step spherical interpolation, pulsating live aircraft heading marker, and departure/arrival IATA beacons.
  - **Mobile Controls**: Interactive pinch-to-zoom, pan, route auto-fit (`fitCamera`), zoom buttons, and live telemetry HUD.
  - **Release APK**: Built `apk/skytrack_pro_v1.0.2.apk`.

---

## ver 1.0.1
- **Date**: 13 November 2026
- **Status**: Production Release Update
- **Author/Manager**: Shoyeb Ahammed
- **Summary**:
  - **Airplane Status Line Fix**: Redesigned `FlightRouteProgress` using `_FlightTrackWidget`. Airplane icon rotated 90° (`math.pi / 2`) to point forward towards destination (`→`). Fixed landed alignment to eliminate the line overflow.
  - **Mobile-Optimized World Map**: Added initial map view and auto-framed route focus.
  - **Clean Commercial UI**: Removed all "minimal API", "demo mode", and "rubric checklist" banners and text from the Home, Analytics, and Settings screens.
  - **App Launcher Icons**: Designed and generated high-resolution launcher icons across all Android mipmap densities (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) and web targets.
  - **Release APK**: Built `apk/skytrack_pro_v1.0.1.apk`.

---

## ver 1.0.0
- **Date**: 13 November 2026
- **Status**: Stable / Initial Implementation
- **Author/Manager**: Shoyeb Ahammed
- **Summary**:
  - Initial project setup, Clean Architecture (`core/`, `data/`, `presentation/`), and Hive local storage integration.
  - Implemented full local CRUD operations (Create, Read, Update, Delete) with Undo support.
  - Infinite scroll pagination with offset/limit.
  - Digital Boarding Pass view and Analytics charts (`fl_chart`).
  - First APK build generated (`apk/skytrack_pro_v1.0.0.apk`).
