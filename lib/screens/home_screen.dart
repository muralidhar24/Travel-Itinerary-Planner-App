import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_router.dart';
import '../utils/constants.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DestinationProvider>(context, listen: false).loadDestinations();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
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
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => AppRouter.goToNotifications(context),
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            _buildCategoriesSection(),
            _buildPopularDestinationsSection(),
            _buildRecentlyViewedSection(),
          ],
        ),
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

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${authProvider.currentUser?.name ?? 'Traveler'}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Where would you like to go today?',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final categories = [
      {'name': 'Beach', 'icon': Icons.beach_access, 'color': Colors.blue},
      {'name': 'Mountain', 'icon': Icons.landscape, 'color': Colors.green},
      {'name': 'City', 'icon': Icons.location_city, 'color': Colors.orange},
      {'name': 'Adventure', 'icon': Icons.hiking, 'color': Colors.red},
      {'name': 'Culture', 'icon': Icons.museum, 'color': Colors.purple},
      {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  context.push('/destinations?category=${category['name']}');
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 60),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: (category['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDestinationsSection() {
    return Consumer<DestinationProvider>(
      builder: (context, destinationProvider, child) {
        final theme = Theme.of(context);
        final popularDestinations = destinationProvider.destinations
            .where((d) => d.rating >= 4.5)
            .take(5)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Popular Indian Destinations',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/destinations'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            if (destinationProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (popularDestinations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                child: Text('No popular destinations found'),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  itemCount: popularDestinations.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                      child: DestinationCard(
                        destination: popularDestinations[index],
                        onTap: () {
                          context.push('/destinations/${popularDestinations[index].id}');
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Consumer<DestinationProvider>(
      builder: (context, destinationProvider, child) {
        final theme = Theme.of(context);
        final recentDestinations = destinationProvider.destinations.take(3).toList();

        if (recentDestinations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recently Viewed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/destinations'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
              itemCount: recentDestinations.length,
              itemBuilder: (context, index) {
                final destination = recentDestinations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      child: Image.network(
                        destination.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          final theme = Theme.of(context);
                          return Container(
                            width: 60,
                            height: 60,
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      destination.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(destination.location),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(destination.rating.toString()),
                      ],
                    ),
                    onTap: () {
                      context.push('/destinations/${destination.id}');
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
        );
      },
    );
  }
}
