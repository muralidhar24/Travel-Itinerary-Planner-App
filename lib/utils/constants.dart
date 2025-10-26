import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Travel Planner';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF64B5F6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient authBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient authCardGradient = LinearGradient(
    colors: [Color(0xCCFFFFFF), Color(0xB3F8FAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient authIconGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingExtraLarge = 40.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  // Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow buttonShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  // Activity Types
  static const List<String> activityTypes = [
    'visit',
    'meal',
    'transport',
    'accommodation',
    'other',
  ];
  
  // Activity Type Colors
  static const Map<String, Color> activityTypeColors = {
    'visit': Color(0xFF4CAF50),
    'meal': Color(0xFFFF9800),
    'transport': Color(0xFF2196F3),
    'accommodation': Color(0xFF9C27B0),
    'other': Color(0xFF607D8B),
  };
  
  // Activity Type Icons
  static const Map<String, IconData> activityTypeIcons = {
    'visit': Icons.place,
    'meal': Icons.restaurant,
    'transport': Icons.directions_car,
    'accommodation': Icons.hotel,
    'other': Icons.event,
  };
  
  // Destination Categories
  static const List<String> destinationCategories = [
    'City',
    'Beach',
    'Island',
    'Mountain',
    'Desert',
    'Forest',
  ];
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'City': Color(0xFF2196F3),
    'Beach': Color(0xFF00BCD4),
    'Island': Color(0xFF4CAF50),
    'Mountain': Color(0xFF795548),
    'Desert': Color(0xFFFF9800),
    'Forest': Color(0xFF8BC34A),
  };
  
  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'City': Icons.location_city,
    'Beach': Icons.beach_access,
    'Island': Icons.terrain,
    'Mountain': Icons.landscape,
    'Desert': Icons.wb_sunny,
    'Forest': Icons.park,
  };
  
  // API Endpoints (Mock)
  static const String baseUrl = 'https://api.travelplanner.com';
  static const String authEndpoint = '/auth';
  static const String destinationsEndpoint = '/destinations';
  static const String itinerariesEndpoint = '/itineraries';
  
  // Storage Keys
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';
  static const String favoritesKey = 'favorite_destinations';
  static const String itinerariesKey = 'user_itineraries';
  static const String settingsKey = 'app_settings';
  
  // Validation - Google-like password policy requirements
  static const int minPasswordLength = 8;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumber = true;
  static const bool requireSpecialCharacter = true;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Map Settings
  static const double defaultZoom = 14.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 20.0;
  
  // Image Settings
  static const double maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String validationError = 'Please check your input and try again.';
}