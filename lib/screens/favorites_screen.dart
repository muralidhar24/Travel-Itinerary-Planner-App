import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/destination_provider.dart';
import '../utils/constants.dart';
import '../widgets/destination_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 2; // Favorites tab index

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
        // Already on favorites
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
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, destinationProvider, child) {
          final favoriteDestinations = destinationProvider.destinations
              .where((destination) => destination.isFavorite)
              .toList();

          if (destinationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteDestinations.isEmpty) {
            return _buildEmptyState();
          }

          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          final crossAxisCount = isLandscape ? 3 : 2;
          
          return Column(
            children: [
              // Stats section
              _buildStatsSection(favoriteDestinations),
              
              // Favorites list
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                  ),
                  itemCount: favoriteDestinations.length,
                  itemBuilder: (context, index) {
                    final destination = favoriteDestinations[index];
                    return DestinationCard(
                      destination: destination,
                      onTap: () {
                        context.push('/destinations/${destination.id}');
                      },
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Start exploring and add destinations\nto your favorites!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            ElevatedButton.icon(
              onPressed: () => context.go('/destinations'),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Destinations'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Search Destinations'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List favoriteDestinations) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Calculate stats
    final categories = <String, int>{};
    double totalRating = 0;
    double totalPrice = 0;
    int pricedDestinations = 0;

    for (final destination in favoriteDestinations) {
      // Count categories
      categories[destination.category] = (categories[destination.category] ?? 0) + 1;
      
      // Sum ratings
      totalRating += destination.rating;
      
      // Sum prices
      if (destination.price > 0) {
        totalPrice += destination.price;
        pricedDestinations++;
      }
    }

    final averageRating = favoriteDestinations.isNotEmpty 
        ? totalRating / favoriteDestinations.length 
        : 0.0;
    final averagePrice = pricedDestinations > 0 
        ? totalPrice / pricedDestinations 
        : 0.0;

    // Responsive padding and sizing
    final margin = isLandscape 
        ? const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall)
        : const EdgeInsets.all(AppConstants.paddingMedium);
    final padding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium)
        : const EdgeInsets.all(AppConstants.paddingLarge);
    final categoryFontSize = isLandscape ? 11.0 : 12.0;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: isLandscape
          ? _buildCompactStatsLayout(
              theme, averageRating, favoriteDestinations, averagePrice, categories, categoryFontSize)
          : _buildExpandedStatsLayout(
              theme, averageRating, favoriteDestinations, averagePrice, categories),
    );
  }

  Widget _buildCompactStatsLayout(
    ThemeData theme,
    double averageRating,
    List favoriteDestinations,
    double averagePrice,
    Map<String, int> categories,
    double categoryFontSize,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Favorites Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 85,
                  child: _buildCompactStatItem(
                    'Total',
                    favoriteDestinations.length.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 85,
                  child: _buildCompactStatItem(
                    'Rating',
                    averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                if (averagePrice > 0) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 85,
                    child: _buildCompactStatItem(
                      'Price',
                      '\$${averagePrice.toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: categories.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(color: AppConstants.primaryColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    '${entry.key} (${entry.value})',
                    style: TextStyle(
                      fontSize: categoryFontSize,
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedStatsLayout(
    ThemeData theme,
    double averageRating,
    List favoriteDestinations,
    double averagePrice,
    Map<String, int> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Favorites Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: _buildStatItem(
                  'Total',
                  favoriteDestinations.length.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              SizedBox(
                width: 100,
                child: _buildStatItem(
                  'Avg Rating',
                  averageRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              if (averagePrice > 0) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                SizedBox(
                  width: 100,
                  child: _buildStatItem(
                    'Avg Price',
                    '\$${averagePrice.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: categories.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.35)),
                ),
                child: Text(
                  '${entry.key} (${entry.value})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
