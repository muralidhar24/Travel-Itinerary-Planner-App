import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(time);
  }

  static String formatDateTime(DateTime dateTime, {String pattern = 'MMM dd, yyyy HH:mm'}) {
    return DateFormat(pattern).format(dateTime);
  }

  static String formatDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('dd, yyyy').format(endDate)}';
    } else if (startDate.year == endDate.year) {
      return '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
    } else {
      return '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}';
    }
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static String getDurationText(DateTime startDate, DateTime endDate) {
    final duration = endDate.difference(startDate).inDays + 1;
    if (duration == 1) {
      return '1 day';
    } else if (duration < 7) {
      return '$duration days';
    } else if (duration < 30) {
      final weeks = (duration / 7).floor();
      final remainingDays = duration % 7;
      if (remainingDays == 0) {
        return '${weeks} week${weeks > 1 ? 's' : ''}';
      } else {
        return '${weeks} week${weeks > 1 ? 's' : ''}, $remainingDays day${remainingDays > 1 ? 's' : ''}';
      }
    } else {
      final months = (duration / 30).floor();
      final remainingDays = duration % 30;
      if (remainingDays == 0) {
        return '${months} month${months > 1 ? 's' : ''}';
      } else {
        return '${months} month${months > 1 ? 's' : ''}, $remainingDays day${remainingDays > 1 ? 's' : ''}';
      }
    }
  }

  // Currency formatting
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      symbol: getCurrencySymbol(currency),
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }

  // String utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    if (password.length < AppConstants.minPasswordLength) {
      return false;
    }

    final hasUppercase = !AppConstants.requireUppercase || password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = !AppConstants.requireLowercase || password.contains(RegExp(r'[a-z]'));
    final hasNumber = !AppConstants.requireNumber || password.contains(RegExp(r'[0-9]'));
    final hasSpecial = !AppConstants.requireSpecialCharacter || password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\[\];\\/~`+=_-]'));

    return hasUppercase && hasLowercase && hasNumber && hasSpecial;
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phoneNumber);
  }

  // Color utilities
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Rating utilities
  static List<Widget> buildStarRating(double rating, {double size = 16, Color? color}) {
    final stars = <Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star,
        size: size,
        color: color ?? Colors.amber,
      ));
    }
    
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half,
        size: size,
        color: color ?? Colors.amber,
      ));
    }
    
    final emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(
        Icons.star_border,
        size: size,
        color: color ?? Colors.amber,
      ));
    }
    
    return stars;
  }

  // Distance calculation
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }

  // Snackbar utilities
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Image utilities
  static String getImageUrl(String? url, {String placeholder = ''}) {
    if (url == null || url.isEmpty) {
      return placeholder.isNotEmpty 
          ? placeholder 
          : 'https://via.placeholder.com/400x300?text=No+Image';
    }
    return url;
  }

  // List utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }
}