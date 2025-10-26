import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/destinations_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/itinerary_screen.dart';
import '../screens/create_itinerary_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/language_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String destinations = '/destinations';
  static const String destinationDetail = '/destinations/:id';
  static const String mapView = '/map';
  static const String favorites = '/favorites';
  static const String itineraryPlanner = '/itinerary';
  static const String itineraryDetail = '/itinerary/:id';
  static const String createItinerary = '/itinerary/create';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String bookings = '/bookings';
  static const String language = '/language';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const AuthScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Destination Routes
      GoRoute(
        path: destinations,
        name: 'destinations',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return DestinationsScreen(category: category);
        },
      ),
      GoRoute(
        path: destinationDetail,
        name: 'destination-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DestinationDetailScreen(destinationId: id);
        },
      ),
      
      // Map Route
      GoRoute(
        path: mapView,
        name: 'map',
        builder: (context, state) {
          return const MapScreen();
        },
      ),
      
      // Favorites Route
      GoRoute(
        path: favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      
      // Itinerary Routes
      GoRoute(
        path: itineraryPlanner,
        name: 'itinerary-planner',
        builder: (context, state) => const ItineraryScreen(),
      ),
      GoRoute(
        path: itineraryDetail,
        name: 'itinerary-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CreateItineraryScreen(itineraryId: id);
        },
      ),
      GoRoute(
        path: createItinerary,
        name: 'create-itinerary',
        builder: (context, state) => const CreateItineraryScreen(),
      ),
      
      // Search Route
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) {
          return const SearchScreen();
        },
      ),
      
      // Profile Routes
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const ProfileScreen(), // Using ProfileScreen for settings too
      ),
      
      // Notifications Route
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Bookings Route
      GoRoute(
        path: bookings,
        name: 'bookings',
        builder: (context, state) => const BookingsScreen(),
      ),
      
      // Language Route
      GoRoute(
        path: language,
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation helper methods
  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToSignup(BuildContext context) {
    context.go(signup);
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToDestinations(BuildContext context, {String? category}) {
    if (category != null) {
      context.go('$destinations?category=$category');
    } else {
      context.go(destinations);
    }
  }

  static void goToDestinationDetail(BuildContext context, String destinationId) {
    context.push('/destinations/$destinationId');
  }

  static void goToMapView(BuildContext context, {String? destinationId}) {
    if (destinationId != null) {
      context.go('$mapView?destination=$destinationId');
    } else {
      context.go(mapView);
    }
  }

  static void goToFavorites(BuildContext context) {
    context.go(favorites);
  }

  static void goToItineraryPlanner(BuildContext context) {
    context.go(itineraryPlanner);
  }

  static void goToItineraryDetail(BuildContext context, String itineraryId) {
    context.go('/itinerary/$itineraryId');
  }

  static void goToCreateItinerary(BuildContext context) {
    context.go(createItinerary);
  }

  static void goToSearch(BuildContext context, {String? query}) {
    if (query != null) {
      context.go('$search?q=$query');
    } else {
      context.go(search);
    }
  }

  static void goToProfile(BuildContext context) {
    context.go(profile);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  static void goToNotifications(BuildContext context) {
    context.push(notifications);
  }

  static void goToBookings(BuildContext context) {
    context.go(bookings);
  }

  static void goToLanguage(BuildContext context) {
    context.go(language);
  }
}