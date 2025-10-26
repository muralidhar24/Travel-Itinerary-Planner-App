import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'update', 'booking', 'reminder', 'general'
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      isRead: json['isRead'] ?? false,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    String? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  bool _notificationsEnabled = true;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    await _loadNotifications();
    await _loadSettings();
    
    // Add welcome notification if first time
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      await addNotification(
        title: 'Welcome to Travel Planner!',
        message: 'Start exploring amazing destinations and plan your perfect trip.',
        type: 'general',
      );
      await prefs.setBool('first_time', false);
    }
  }

  Future<void> _loadNotifications() async {
    try {
      // In production, implement proper JSON decoding here
      // final prefs = await SharedPreferences.getInstance();
      // final notificationsJson = prefs.getStringList('notifications') ?? [];
      // 
      // _notifications.clear();
      // for (final jsonStr in notificationsJson) {
      //   try {
      //     final notification = NotificationItem.fromJson(jsonDecode(jsonStr));
      //     _notifications.add(notification);
      //   } catch (e) {
      //     debugPrint('Error parsing notification: $e');
      //   }
      // }
      
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    try {
      // In a real app, use proper JSON encoding
      // For now, we'll keep notifications in memory only
      // final prefs = await SharedPreferences.getInstance();
      // final notificationsJson = _notifications.map((n) => jsonEncode(n.toJson())).toList();
      // await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Simulate receiving a new update notification
  Future<void> sendUpdateNotification(String feature) async {
    if (_notificationsEnabled) {
      await addNotification(
        title: 'New Feature Available!',
        message: feature,
        type: 'update',
      );
    }
  }

  // Send booking notification
  Future<void> sendBookingNotification(String bookingTitle) async {
    if (_notificationsEnabled) {
      await addNotification(
        title: 'Booking Confirmed',
        message: bookingTitle,
        type: 'booking',
      );
    }
  }
}