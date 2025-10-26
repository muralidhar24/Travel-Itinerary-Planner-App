import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/destination_provider.dart';
import '../utils/constants.dart';
import '../widgets/destination_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // In a real app, load from SharedPreferences
    setState(() {
      _recentSearches = [
        'Paris',
        'Tokyo',
        'Beach destinations',
        'Mountain hiking',
      ];
    });
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
    // In a real app, save to SharedPreferences
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    // In a real app, clear from SharedPreferences
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _searchQuery = query;
    });
    _addToRecentSearches(query);
    _searchFocusNode.unfocus();
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
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search destinations...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              // Update UI as user types
            });
          },
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _searchQuery.isEmpty ? _buildSearchSuggestions() : _buildSearchResults(),
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    final popularCategories = [
      {'name': 'Beach', 'icon': Icons.beach_access, 'color': Colors.blue},
      {'name': 'Mountain', 'icon': Icons.landscape, 'color': Colors.green},
      {'name': 'City', 'icon': Icons.location_city, 'color': Colors.orange},
      {'name': 'Adventure', 'icon': Icons.hiking, 'color': Colors.red},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular categories
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
            ),
            itemCount: popularCategories.length,
            itemBuilder: (context, index) {
              final category = popularCategories[index];
              return InkWell(
                onTap: () {
                  context.go('/destinations', extra: {'category': category['name']});
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Container(
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: (category['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          color: category['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final search = _recentSearches[index];
                return ListTile(
                  leading: Icon(Icons.history, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  title: Text(search),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    onPressed: () {
                      setState(() {
                        _recentSearches.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                );
              },
            ),
          ],

          // Search tips
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  '• Try searching by destination name (e.g., "Paris", "Tokyo")',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  '• Search by category (e.g., "beach", "mountain", "city")',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  '• Use specific terms (e.g., "hiking trails", "cultural sites")',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    
    return Consumer<DestinationProvider>(
      builder: (context, destinationProvider, child) {
        final searchResults = destinationProvider.destinations.where((destination) {
          final query = _searchQuery.toLowerCase();
          return destination.name.toLowerCase().contains(query) ||
                 destination.location.toLowerCase().contains(query) ||
                 destination.category.toLowerCase().contains(query) ||
                 destination.description.toLowerCase().contains(query);
        }).toList();

        if (destinationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'No results found for "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Try different keywords or browse categories',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Text(
                '${searchResults.length} results for "$_searchQuery"',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: AppConstants.paddingMedium,
                  mainAxisSpacing: AppConstants.paddingMedium,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final destination = searchResults[index];
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
    );
  }
}
