import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  final Destination? selectedDestination;

  const MapScreen({
    super.key,
    this.selectedDestination,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Destination? _selectedDestination;
  bool _showDestinationsList = false;

  static const double _indiaMinLatitude = 6.0;
  static const double _indiaMaxLatitude = 37.5;
  static const double _indiaMinLongitude = 68.0;
  static const double _indiaMaxLongitude = 97.5;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.selectedDestination;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: Icon(
              _showDestinationsList ? Icons.map : Icons.list,
            ),
            onPressed: () {
              setState(() {
                _showDestinationsList = !_showDestinationsList;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Handle current location
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Current location feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder
          _buildMapView(),
          
          // Destinations list overlay
          if (_showDestinationsList) _buildDestinationsListOverlay(),
          
          // Selected destination info
          if (_selectedDestination != null && !_showDestinationsList)
            _buildSelectedDestinationInfo(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: () {
              // Handle zoom in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoom in')),
              );
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: () {
              // Handle zoom out
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zoom out')),
              );
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static India background image
          Image.asset(
            'assets/images/india_map.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text('India map image missing'),
              );
            },
          ),
          Consumer<DestinationProvider>(
            builder: (context, destinationProvider, child) {
              if (destinationProvider.destinations.isEmpty) {
                return const SizedBox.shrink();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  const double markerDiameter = 36;

                  return Stack(
                    children: destinationProvider.destinations.map((destination) {
                      final bool isSelected = _selectedDestination?.id == destination.id;
                      final Color markerBackground =
                          isSelected ? AppConstants.primaryColor : Colors.white;
                      final Color markerIconColor =
                          isSelected ? Colors.white : AppConstants.primaryColor;

                      final double normalizedLongitude =
                          (destination.longitude - _indiaMinLongitude) /
                              (_indiaMaxLongitude - _indiaMinLongitude);
                      final double normalizedLatitude =
                          (_indiaMaxLatitude - destination.latitude) /
                              (_indiaMaxLatitude - _indiaMinLatitude);

                      final double leftPosition =
                          (constraints.maxWidth - markerDiameter) * normalizedLongitude;
                      final double topPosition =
                          (constraints.maxHeight - markerDiameter) * normalizedLatitude;

                      return Positioned(
                        left: leftPosition.clamp(0.0, constraints.maxWidth - markerDiameter),
                        top: topPosition.clamp(0.0, constraints.maxHeight - markerDiameter),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDestination = destination;
                              _showDestinationsList = false;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: markerBackground,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: markerIconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    destination.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsListOverlay() {
    return Consumer<DestinationProvider>(
      builder: (context, destinationProvider, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.white.withValues(alpha: 0.98),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppConstants.primaryColor),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        '${destinationProvider.destinations.length} Destinations',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: destinationProvider.destinations.length,
                    itemBuilder: (context, index) {
                      final destination = destinationProvider.destinations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            child: Image.network(
                              destination.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            destination.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(destination.location),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(destination.rating.toString()),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      destination.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.location_searching),
                            onPressed: () {
                              setState(() {
                                _selectedDestination = destination;
                                _showDestinationsList = false;
                              });
                            },
                          ),
                          onTap: () {
                            context.push('/destinations/${destination.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDestinationInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    child: Image.network(
                      _selectedDestination!.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDestination!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDestination!.location,
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(_selectedDestination!.rating.toString()),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _selectedDestination!.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          context.push('/destinations/${_selectedDestination!.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedDestination = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                bottom: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle directions
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Directions feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/destinations/${_selectedDestination!.id}');
                      },
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
