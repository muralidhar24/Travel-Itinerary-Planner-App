import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../providers/itinerary_provider.dart';
import '../utils/constants.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DestinationProvider>(
      builder: (context, destinationProvider, child) {
        final destination = destinationProvider.destinations
            .where((d) => d.id == widget.destinationId)
            .firstOrNull;

        if (destination == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Destination')),
            body: const Center(
              child: Text('Destination not found'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(destination),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(destination),
                    _buildDescription(destination),
                    _buildHighlights(destination),
                    _buildLocationInfo(destination),
                    _buildActionButtons(destination),
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Destination destination) {
    final images = [destination.imageUrl]; // In real app, would have multiple images

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                );
              },
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
            // Image indicators
            if (images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        Consumer<DestinationProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: destination.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                provider.toggleFavorite(destination.id);
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Handle share
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfo(Destination destination) {
    final theme = Theme.of(context);
    final Color onSurface = theme.colorScheme.onSurface;
    final Color secondaryText = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  destination.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  destination.category,
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  destination.location,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    destination.rating.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${(destination.rating * 100).toInt()} reviews)',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (destination.price > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${destination.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'per person',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Destination destination) {
    final theme = Theme.of(context);
    final Color onSurface = theme.colorScheme.onSurface;
    final Color secondaryText = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            destination.description,
            style: TextStyle(
              fontSize: 16,
              color: secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(Destination destination) {
    final theme = Theme.of(context);
    final Color onSurface = theme.colorScheme.onSurface;
    final Color secondaryText = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final Color chipBackground = theme.colorScheme.surfaceContainerHighest;

    final highlights = [
      'Beautiful scenery',
      'Rich culture',
      'Great food',
      'Adventure activities',
      'Historical sites',
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Highlights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: highlights.map((highlight) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  highlight,
                  style: TextStyle(
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Destination destination) {
    final theme = Theme.of(context);
    final Color onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  child: Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Map View',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      onTap: () {
                        context.go('/map', extra: destination);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Destination destination) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddToItineraryDialog(destination);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add to Itinerary'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/map', extra: destination);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('View on Map'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/bookings');
                  },
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddToItineraryDialog(Destination destination) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ItineraryProvider>(
          builder: (context, itineraryProvider, child) {
            final itineraries = itineraryProvider.itineraries;

            return AlertDialog(
              title: const Text('Add to Itinerary'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (itineraries.isEmpty)
                    const Text('No itineraries found. Create one first!')
                  else
                    ...itineraries.map((itinerary) {
                      return ListTile(
                        title: Text(itinerary.title),
                        subtitle: Text('${itinerary.days.length} days'),
                        onTap: () {
                          // Add destination to itinerary
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to ${itinerary.title}'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/itinerary/create');
                  },
                  child: const Text('Create New'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
