import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/itinerary_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Profile tab index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/itinerary');
        break;
      case 4:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  final unreadCount = notificationService.unreadCount;
                  if (unreadCount == 0) return const SizedBox.shrink();
                  
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              _showSettingsBottomSheet();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user),
                _buildStatsSection(),
                _buildMenuSection(),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                child: user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty
                    ? ClipOval(
                        child: Image.file(
                          File(user.profileImagePath!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return const Icon(
                              Icons.person,
                              size: 50,
                              color: AppConstants.primaryColor,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () => _showImagePickerOptions(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton.icon(
            onPressed: () {
              _showEditProfileDialog();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer2<DestinationProvider, ItineraryProvider>(
      builder: (context, destinationProvider, itineraryProvider, child) {
        final favoriteCount = destinationProvider.destinations
            .where((d) => d.isFavorite)
            .length;
        final itineraryCount = itineraryProvider.itineraries.length;
        final visitedCount = 0; // In a real app, track visited destinations

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Favorites', favoriteCount.toString(), Icons.favorite),
              _buildStatItem('Itineraries', itineraryCount.toString(), Icons.calendar_today),
              _buildStatItem('Visited', visitedCount.toString(), Icons.check_circle),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'title': 'My Bookings',
        'subtitle': 'View and manage your bookings',
        'icon': Icons.book_online,
        'onTap': () {
          context.push('/bookings');
        },
      },
      {
        'title': 'Travel Preferences',
        'subtitle': 'Set your travel preferences',
        'icon': Icons.tune,
        'onTap': () {
          _showTravelPreferencesDialog();
        },
      },
      {
        'title': 'Notifications',
        'subtitle': 'Manage notification settings',
        'icon': Icons.notifications,
        'onTap': () {
          _showNotificationSettings();
        },
      },
      {
        'title': 'Privacy & Security',
        'subtitle': 'Manage your privacy settings',
        'icon': Icons.security,
        'onTap': () {
          _showPrivacySettings();
        },
      },
      {
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'icon': Icons.help,
        'onTap': () {
          _showHelpDialog();
        },
      },
      {
        'title': 'About',
        'subtitle': 'App version and information',
        'icon': Icons.info,
        'onTap': () {
          _showAboutDialog();
        },
      },
    ];

    return Column(
      children: [
        const SizedBox(height: AppConstants.paddingLarge),
        ...menuItems.map((item) {
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingSmall,
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: AppConstants.primaryColor,
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(item['subtitle'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: item['onTap'] as VoidCallback,
            ),
          );
        }).toList(),
        
        // Logout button
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            onTap: _showLogoutConfirmation,
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppConstants.primaryColor),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppConstants.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _removeProfilePicture();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Copy image to app's document directory for permanent storage
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final String localPath = path.join(appDir.path, fileName);
        
        // Copy the file
        final File imageFile = File(image.path);
        await imageFile.copy(localPath);
        
        // Update user profile with the permanent image path
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final updatedUser = authProvider.currentUser?.copyWith(
          profileImagePath: localPath,
        );

        if (updatedUser != null) {
          await authProvider.updateProfile(updatedUser);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Update notification
          await NotificationService.instance.addNotification(
            title: 'Profile Updated',
            message: 'Your profile picture has been updated successfully.',
            type: 'general',
          );
        }
      }
    } catch (e) {
      print('Error picking/saving image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeProfilePicture() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updatedUser = authProvider.currentUser?.copyWith(
      clearProfileImage: true,
    );

    if (updatedUser != null) {
      await authProvider.updateProfile(updatedUser);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture removed')),
      );
    }
  }

  void _showEditProfileDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    firstNameController.text = authProvider.currentUser?.firstName ?? '';
    lastNameController.text = authProvider.currentUser?.lastName ?? '';
    final email = authProvider.currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Builder(
                builder: (context) {
                  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                  return TextField(
                    enabled: false,
                    controller: TextEditingController(text: email),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: isDarkMode 
                        ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                        : Colors.grey[200],
                    ),
                    style: TextStyle(
                      color: isDarkMode 
                        ? Theme.of(context).colorScheme.onSurface
                        : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              const Text(
                'Email cannot be changed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = authProvider.currentUser?.copyWith(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
              );

              if (updatedUser == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No user to update.')),
                );
                return;
              }

              final success = await authProvider.updateProfile(updatedUser);
              if (!context.mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Profile updated!' : authProvider.errorMessage ?? 'Failed to update profile.',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.setDarkMode(value);
                      },
                    ),
                  );
                },
              ),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  return ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(languageProvider.currentLanguageName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/language');
                    },
                  );
                },
              ),
              Consumer<LocationService>(
                builder: (context, locationService, _) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Location Services'),
                    trailing: Switch(
                      value: locationService.locationEnabled,
                      onChanged: (value) async {
                        await locationService.setLocationEnabled(value);
                        if (value && !locationService.permissionGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  locationService.errorMessage ?? 
                                  'Please enable location permissions in settings'
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTravelPreferencesDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    final List<String> allPreferences = [
      'Adventure',
      'Relaxation',
      'Cultural',
      'Historical',
      'Nature',
      'Beach',
      'Mountain',
      'City Exploration',
      'Food & Cuisine',
      'Wildlife',
      'Photography',
      'Budget Travel',
      'Luxury Travel',
      'Eco-Tourism',
    ];
    
    final selectedPreferences = currentUser?.travelPreferences.toList() ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Travel Preferences'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your travel interests:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ...allPreferences.map((preference) {
                    return CheckboxListTile(
                      title: Text(preference),
                      value: selectedPreferences.contains(preference),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedPreferences.contains(preference)) {
                              selectedPreferences.add(preference);
                            }
                          } else {
                            selectedPreferences.removeWhere((p) => p == preference);
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (currentUser != null) {
                    final updatedUser = currentUser.copyWith(
                      travelPreferences: selectedPreferences,
                    );
                    
                    final success = await authProvider.updateProfile(updatedUser);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Travel preferences updated successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ?? 'Failed to update preferences'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Consumer<NotificationService>(
          builder: (context, notificationService, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive app notifications'),
                  value: notificationService.notificationsEnabled,
                  onChanged: (value) async {
                    await notificationService.setNotificationsEnabled(value);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Notification Types'),
                  subtitle: const Text('Updates, Bookings, Reminders'),
                  dense: true,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const Text('Privacy & Security'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Privacy'),
                    Tab(text: 'Security'),
                  ],
                  labelColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Privacy Tab
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.visibility),
                              title: const Text('Profile Visibility'),
                              subtitle: const Text('Control who can see your profile'),
                              onTap: () => _showProfileVisibilityOptions(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Data Sharing'),
                              subtitle: const Text('Control data sharing preferences'),
                              onTap: () => _showDataSharingOptions(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: const Text('Location Tracking'),
                              subtitle: const Text('Manage location data usage'),
                              onTap: () => _showLocationTrackingOptions(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: const Text('Activity History'),
                              subtitle: const Text('Manage your activity logs'),
                              onTap: () => _showActivityHistoryOptions(),
                            ),
                          ],
                        ),
                      ),
                      // Security Tab
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.lock),
                              title: const Text('Change Password'),
                              subtitle: const Text('Update your password'),
                              onTap: () => _showChangePasswordDialog(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.verified_user),
                              title: const Text('Two-Factor Authentication'),
                              subtitle: const Text('Add an extra layer of security'),
                              onTap: () => _showTwoFactorDialog(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.devices),
                              title: const Text('Active Sessions'),
                              subtitle: const Text('View and manage your sessions'),
                              onTap: () => _showActiveSessions(),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.security),
                              title: const Text('Security Checkup'),
                              subtitle: const Text('Review your account security'),
                              onTap: () => _showSecurityCheckup(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileVisibilityOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Public'),
              subtitle: const Text('Anyone can view your profile'),
              value: 'public',
              groupValue: 'public',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile visibility updated to Public')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Friends Only'),
              subtitle: const Text('Only your friends can view'),
              value: 'friends',
              groupValue: 'public',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile visibility updated to Friends Only')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Private'),
              subtitle: const Text('Only you can view your profile'),
              value: 'private',
              groupValue: 'public',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile visibility updated to Private')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDataSharingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Sharing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Share Analytics'),
              subtitle: const Text('Help improve app with usage data'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Analytics ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Share Preferences'),
              subtitle: const Text('Share travel preferences for recommendations'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preferences sharing ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Marketing Communications'),
              subtitle: const Text('Receive promotional emails'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Marketing emails ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLocationTrackingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Tracking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Precise Location'),
              subtitle: const Text('Allow app to use precise location'),
              value: true,
              onChanged: (value) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location tracking ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Location History'),
              subtitle: const Text('Save your location history'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location history ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Location data helps us show nearby destinations and improve recommendations.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showActivityHistoryOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Activity History'),
              subtitle: const Text('Delete all your activity logs'),
              onTap: () {
                Navigator.pop(context);
                _showClearHistoryConfirmation();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Activity'),
              subtitle: const Text('See your recent activities'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recent: Viewed Goa, Added Itinerary, Favorited Delhi')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Activity History?'),
        content: const Text('This action cannot be undone. All your activity logs will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity history cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  TextField(
                    controller: currentPasswordCtrl,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordCtrl,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      helperText: 'Min 8 chars, uppercase, lowercase, number, special char',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      currentPasswordCtrl.dispose();
                      newPasswordCtrl.dispose();
                      confirmPasswordCtrl.dispose();
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validation
                      if (currentPasswordCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your current password')),
                        );
                        return;
                      }

                      if (newPasswordCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a new password')),
                        );
                        return;
                      }

                      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                        return;
                      }

                      // Call the password change service
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        await authProvider.changePassword(
                          currentPasswordCtrl.text,
                          newPasswordCtrl.text,
                        );

                        currentPasswordCtrl.dispose();
                        newPasswordCtrl.dispose();
                        confirmPasswordCtrl.dispose();

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Two-factor authentication adds an extra layer of security to your account.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Methods:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.sms),
              title: const Text('SMS'),
              subtitle: const Text('Receive codes via text message'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Setting up SMS 2FA...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Authenticator App'),
              subtitle: const Text('Use Google Authenticator or similar'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan QR code with your authenticator app')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Windows - Chrome'),
                subtitle: const Text('Current session • 192.168.1.1'),
                trailing: const Text('Active', style: TextStyle(color: Colors.green)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Android Phone'),
                subtitle: const Text('Last active 2 hours ago'),
                trailing: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Session ended')),
                    );
                  },
                  child: const Text('Sign out'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.tablet_mac),
                title: const Text('iPad - Safari'),
                subtitle: const Text('Last active 1 day ago'),
                trailing: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Session ended')),
                    );
                  },
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecurityCheckup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Checkup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSecurityCheckItem(
                'Password Strength',
                'Strong',
                Colors.green,
              ),
              const Divider(),
              _buildSecurityCheckItem(
                'Two-Factor Authentication',
                'Not enabled',
                Colors.orange,
              ),
              const Divider(),
              _buildSecurityCheckItem(
                'Recovery Email',
                'Verified',
                Colors.green,
              ),
              const Divider(),
              _buildSecurityCheckItem(
                'Active Sessions',
                '3 devices',
                Colors.blue,
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Tip: Enable two-factor authentication to protect your account from unauthorized access.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCheckItem(String title, String status, Color statusColor) {
    return ListTile(
      title: Text(title),
      trailing: Chip(
        label: Text(status),
        backgroundColor: statusColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: AppConstants.paddingMedium),
            Text('📧 support@travelplan.com'),
            Text('📞 +1 (555) 123-4567'),
            Text('💬 Live chat available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening support chat...')),
              );
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.travel_explore,
        size: 48,
        color: AppConstants.primaryColor,
      ),
      children: const [
        Text('Plan, organize and share your travel itineraries with ease.'),
        SizedBox(height: 16),
        Text('© 2024 TravelPlan. All rights reserved.'),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
        Text(
          'About Me',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text('Developed by Dasari Muralidhar.'),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
