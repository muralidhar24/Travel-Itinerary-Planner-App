import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/destination_provider.dart';
import '../utils/constants.dart';
import '../widgets/destination_card.dart';

class DestinationsScreen extends StatefulWidget {
  final String? category;

  const DestinationsScreen({
    super.key,
    this.category,
  });

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  double _minRating = 0.0;
  RangeValues _priceRange = const RangeValues(0, 1000);

  final List<String> _categories = [
    'All',
    'Beach',
    'Mountain',
    'City',
    'Adventure',
    'Culture',
    'Food',
  ];

  final List<String> _sortOptions = [
    'name',
    'rating',
    'price',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedCategory = widget.category!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DestinationProvider>(context, listen: false).loadDestinations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        title: Text(_selectedCategory == 'All' ? 'Explore India' : _selectedCategory),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, destinationProvider, child) {
          if (destinationProvider.isLoading) {
            return const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          var filteredDestinations = destinationProvider.destinations.where((destination) {
            // Category filter
            if (_selectedCategory != 'All' && destination.category != _selectedCategory) {
              return false;
            }
            // Rating filter
            if (destination.rating < _minRating) {
              return false;
            }
            // Price filter
            if (destination.price < _priceRange.start || destination.price > _priceRange.end) {
              return false;
            }
            return true;
          }).toList();

          // Sort destinations
          switch (_sortBy) {
            case 'rating':
              filteredDestinations.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            case 'price':
              filteredDestinations.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'name':
            default:
              filteredDestinations.sort((a, b) => a.name.compareTo(b.name));
              break;
          }


          if (filteredDestinations.isEmpty) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'No destinations found',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Filter chips
                _buildFilterChips(),
                // Destinations grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: AppConstants.paddingMedium,
                      mainAxisSpacing: AppConstants.paddingMedium,
                    ),
                    itemCount: filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = filteredDestinations[index];
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: theme.colorScheme.surfaceVariant,
              selectedColor: AppConstants.primaryColor.withOpacity(0.15),
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppConstants.primaryColor : theme.colorScheme.onSurface.withOpacity(0.65),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: AppConstants.paddingLarge,
                      right: AppConstants.paddingLarge,
                      top: AppConstants.paddingLarge,
                      bottom: AppConstants.paddingLarge + MediaQuery.of(context).viewPadding.bottom,
                    ),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Wrap(
                        spacing: AppConstants.paddingSmall,
                        children: _sortOptions.map((option) {
                          return ChoiceChip(
                            label: Text(option.toUpperCase()),
                            selected: _sortBy == option,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  _sortBy = option;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: _minRating,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        label: _minRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setModalState(() {
                            _minRating = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 2000,
                        divisions: 20,
                        labels: RangeLabels(
                          '\$${_priceRange.start.round()}',
                          '\$${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Filters are already applied through state
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedCategory = 'All';
                              _sortBy = 'name';
                              _minRating = 0.0;
                              _priceRange = const RangeValues(0, 1000);
                            });
                            setState(() {
                              _selectedCategory = 'All';
                              _sortBy = 'name';
                              _minRating = 0.0;
                              _priceRange = const RangeValues(0, 1000);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
