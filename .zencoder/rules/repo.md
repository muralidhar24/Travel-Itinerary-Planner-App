# Travel Itinerary App Repository Overview

## Project Summary
- **Framework**: Flutter (Dart SDK ^3.8.1)
- **Purpose**: Travel planning app featuring destination discovery, itineraries, favorites, and profile management.
- **Architectural Pattern**: Multi-provider state management with route handling via `go_router`.

## Key Directories
- **lib/**
  - `main.dart`: App entry point, providers, theming, router.
  - `models/`: Data models (`destination.dart`, `itinerary.dart`, `user.dart`).
  - `providers/`: ChangeNotifiers for auth, destinations, itineraries, theme.
  - `screens/`: UI screens such as home, destinations, itinerary, profile, map, search.
  - `services/`: Interaction layer for auth, destinations, itineraries (expand for Supabase integration).
  - `utils/`: Constants, helpers, and router configuration.
  - `widgets/`: Shared UI components (e.g., destination cards).
- **assets/**
  - Organized into `images/`, `icons/`, `animations/` folders. Declared in `pubspec.yaml`.
- **test/**
  - Currently contains `widget_test.dart` placeholder.

## Tooling & Commands
- **Run app**: `flutter run`
- **Analyze**: `flutter analyze`
- **Format**: `dart format lib test`
- **Test**: `flutter test`

## Dependencies Highlights
- **Navigation**: `go_router`
- **State Management**: `provider`
- **Data & Storage**: `http`, `shared_preferences`, `sqflite`
- **Maps & Location**: `google_maps_flutter`, `geolocator`
- **UI Enhancements**: `flutter_staggered_grid_view`, `cached_network_image`, `shimmer`, `lottie`
- **Localization & Utilities**: `intl`, `table_calendar`, `font_awesome_flutter`, `image_picker`

## Pending Enhancements (Requested)
1. Comprehensive localization with English default + 16 additional languages.
2. Supabase-backed profile pictures and bookings (email immutable).
3. Profile screen: read-only email, image upload, "My Bookings" list.
4. Back button on Explore Destinations screen.
5. In-app notifications for:
   - Upcoming bookings
   - New feature announcements
   - New user sign-ins
6. Location services: show current location and nearby destination suggestions.

## Conventions & Notes
- **Theming**: Material 3, light/dark themes defined in `main.dart`.
- **Routing**: Centralized in `lib/utils/app_router.dart`.
- **State Updates**: Use providers; avoid direct setState in shared widgets.
- **Assets**: Ensure new images/icons are registered in `pubspec.yaml`.
- **Supabase Config**: Store keys securely (e.g., `flutter_dotenv`) and avoid committing secrets.

Keep this file updated as major architectural changes are introduced.