import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../utils/constants.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryTextColor = theme.colorScheme.onSurface;
    final Color secondaryTextColor = theme.colorScheme.onSurface.withOpacity(0.72);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusMedium),
                      ),
                      child: Image.network(
                        destination.imageUrl,
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
                      ),
                    ),
                  ),
                if (showFavoriteButton)
                  Positioned(
                    top: AppConstants.paddingSmall,
                    right: AppConstants.paddingSmall,
                    child: Consumer<DestinationProvider>(
                      builder: (context, provider, child) {
                        final theme = Theme.of(context);
                        final bool isDark = theme.brightness == Brightness.dark;

                        return GestureDetector(
                          onTap: () {
                            provider.toggleFavorite(destination.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.paddingSmall),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.65)
                                  : Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              destination.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: destination.isFavorite
                                  ? Colors.red
                                  : (isDark ? Colors.white : Colors.grey[600]),
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Category badge
                Positioned(
                  top: AppConstants.paddingSmall,
                  left: AppConstants.paddingSmall,
                  child: Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final bool isDark = theme.brightness == Brightness.dark;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.primary.withOpacity(0.9)
                              : AppConstants.primaryColor.withOpacity(0.85),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          destination.category,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        if (destination.price > 0)
                          Text(
                            '\$${destination.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
