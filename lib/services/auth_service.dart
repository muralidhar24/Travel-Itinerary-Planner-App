import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_data';
  static const String _currentTokenKey = 'current_auth_token';
  static const String _allUsersKey = 'all_users_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _authToken;
  Map<String, Map<String, dynamic>> _allUsers = {}; // email -> {user, password}

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load all registered users
    final allUsersJson = prefs.getString(_allUsersKey);
    if (allUsersJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(allUsersJson);
      _allUsers = decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
    }
    
    // Load current user data
    final userData = prefs.getString(_currentUserKey);
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
    }
    
    // Load auth token
    _authToken = prefs.getString(_currentTokenKey);
  }

  /// Check if an email is already registered
  Future<bool> isEmailRegistered(String email) async {
    return _allUsers.containsKey(email.toLowerCase().trim());
  }

  /// Get user data by email (without password)
  Future<User?> getUserByEmail(String email) async {
    final userData = _allUsers[email.toLowerCase().trim()];
    if (userData != null && userData['user'] != null) {
      return User.fromJson(userData['user']);
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final emailKey = email.toLowerCase().trim();
      
      // Check if user exists
      if (!_allUsers.containsKey(emailKey)) {
        throw Exception('Email not registered. Please sign up first.');
      }
      
      // Validate password
      final userData = _allUsers[emailKey];
      if (userData == null || userData['password'] != password) {
        throw Exception('Invalid email or password');
      }
      
      // Load user data
      _currentUser = User.fromJson(userData['user']);
      _authToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save current session
      await _saveCurrentSession();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final emailKey = email.toLowerCase().trim();
      
      // Check if email already exists
      if (_allUsers.containsKey(emailKey)) {
        throw Exception('Email already registered. Please login instead.');
      }
      
      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }
      
      if (!Helpers.isValidPassword(password)) {
        throw Exception('Password must include at least ${AppConstants.minPasswordLength} characters, a mix of uppercase and lowercase letters, numbers, and special symbols.');
      }
      
      // Create new user
      final nameParts = name.trim().split(' ');
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.trim(),
        firstName: nameParts.isNotEmpty ? nameParts[0] : 'User',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _authToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save user to all users list
      _allUsers[emailKey] = {
        'user': _currentUser!.toJson(),
        'password': password,
      };
      
      // Save to local storage
      await _saveAllUsers();
      await _saveCurrentSession();
      
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_currentTokenKey);
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
      
      // Update in all users list
      final emailKey = _currentUser!.email.toLowerCase().trim();
      if (_allUsers.containsKey(emailKey)) {
        final password = _allUsers[emailKey]!['password'];
        _allUsers[emailKey] = {
          'user': _currentUser!.toJson(),
          'password': password,
        };
        await _saveAllUsers();
      }
      
      await _saveCurrentSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_currentUser != null && _authToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
      await prefs.setString(_currentTokenKey, _authToken!);
    }
  }

  Future<void> _saveAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_allUsersKey, jsonEncode(_allUsers));
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      final emailKey = email.toLowerCase().trim();
      if (!_allUsers.containsKey(emailKey)) {
        throw Exception('Email not found');
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change password for the current authenticated user
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // Validate inputs
      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('All fields are required');
      }

      // Verify current password
      final emailKey = _currentUser!.email.toLowerCase().trim();
      final userData = _allUsers[emailKey];
      
      if (userData == null || userData['password'] != currentPassword) {
        throw Exception('Current password is incorrect');
      }

      // Validate new password format
      if (!Helpers.isValidPassword(newPassword)) {
        throw Exception('Password must include at least ${AppConstants.minPasswordLength} characters, a mix of uppercase and lowercase letters, numbers, and special symbols.');
      }

      // Prevent using the same password
      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update password in all users list
      _allUsers[emailKey] = {
        'user': _currentUser!.toJson(),
        'password': newPassword,
      };

      // Save to local storage
      await _saveAllUsers();

      return true;
    } catch (e) {
      rethrow;
    }
  }
}