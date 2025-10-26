import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Itinerary tab index
  String _selectedFilter = 'all'; // all, upcoming, current, past
  String _selectedSort = 'date'; // date, name, duration
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _filterTabController;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 4, vsync: this);
    _filterTabController.addListener(() {
      if (!_filterTabController.indexIsChanging) {
        setState(() {
          switch (_filterTabController.index) {
            case 0:
              _selectedFilter = 'all';
              break;
            case 1:
              _selectedFilter = 'upcoming';
              break;
            case 2:
              _selectedFilter = 'current';
              break;
            case 3:
              _selectedFilter = 'past';
              break;
          }
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItineraryProvider>(context, listen: false).loadItineraries();
    });
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
        // Already on itinerary
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  List<Itinerary> _getFilteredAndSortedItineraries(ItineraryProvider provider) {
    List<Itinerary> itineraries;
    
    // Apply filter
    switch (_selectedFilter) {
      case 'upcoming':
        itineraries = provider.upcomingItineraries;
        break;
      case 'current':
        itineraries = provider.currentItineraries;
        break;
      case 'past':
        itineraries = provider.pastItineraries;
        break;
      default:
        itineraries = provider.itineraries;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      itineraries = itineraries.where((itinerary) {
        return itinerary.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               itinerary.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sort
    switch (_selectedSort) {
      case 'name':
        itineraries.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'duration':
        itineraries.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case 'date':
      default:
        itineraries.sort((a, b) => a.startDate.compareTo(b.startDate));
    }

    return itineraries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search itineraries...',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('My Itineraries'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                setState(() {
                  _selectedSort = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'date',
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: _selectedSort == 'date' ? theme.colorScheme.primary : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Date',
                        style: TextStyle(
                          color: _selectedSort == 'date' ? theme.colorScheme.primary : null,
                          fontWeight: _selectedSort == 'date' ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_by_alpha,
                        size: 20,
                        color: _selectedSort == 'name' ? theme.colorScheme.primary : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Name',
                        style: TextStyle(
                          color: _selectedSort == 'name' ? theme.colorScheme.primary : null,
                          fontWeight: _selectedSort == 'name' ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'duration',
                  child: Row(
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 20,
                        color: _selectedSort == 'duration' ? theme.colorScheme.primary : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by Duration',
                        style: TextStyle(
                          color: _selectedSort == 'duration' ? theme.colorScheme.primary : null,
                          fontWeight: _selectedSort == 'duration' ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/itinerary/create'),
            ),
          ],
        ],
      ),
      body: Consumer<ItineraryProvider>(
        builder: (context, itineraryProvider, child) {
          if (itineraryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredItineraries = _getFilteredAndSortedItineraries(itineraryProvider);

          return Column(
            children: [
              // Statistics Card
              if (itineraryProvider.itineraries.isNotEmpty && !_isSearching)
                _buildStatisticsCard(itineraryProvider, theme),
              
              // Filter Tabs
              Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: _filterTabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: theme.colorScheme.primary,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('All'),
                          if (itineraryProvider.itineraries.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'all' 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${itineraryProvider.itineraries.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _selectedFilter == 'all' 
                                      ? Colors.white 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Upcoming'),
                          if (itineraryProvider.upcomingItineraries.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'upcoming' 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${itineraryProvider.upcomingItineraries.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _selectedFilter == 'upcoming' 
                                      ? Colors.white 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Current'),
                          if (itineraryProvider.currentItineraries.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'current' 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${itineraryProvider.currentItineraries.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _selectedFilter == 'current' 
                                      ? Colors.white 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Past'),
                          if (itineraryProvider.pastItineraries.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'past' 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${itineraryProvider.pastItineraries.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _selectedFilter == 'past' 
                                      ? Colors.white 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Itinerary List
              Expanded(
                child: filteredItineraries.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: () => itineraryProvider.refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          itemCount: filteredItineraries.length,
                          itemBuilder: (context, index) {
                            final itinerary = filteredItineraries[index];
                            return _buildItineraryCard(itinerary, itineraryProvider, theme);
                          },
                        ),
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

  Widget _buildStatisticsCard(ItineraryProvider provider, ThemeData theme) {
    double totalBudget = 0;
    int totalDays = 0;
    int totalActivities = 0;
    
    for (var itinerary in provider.itineraries) {
      totalBudget += provider.calculateTotalBudget(itinerary);
      totalDays += itinerary.duration;
      for (var day in itinerary.days) {
        totalActivities += day.activities.length;
      }
    }

    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Travel Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_month,
                    label: 'Total Days',
                    value: totalDays.toString(),
                    color: Colors.blue,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.event_note,
                    label: 'Activities',
                    value: totalActivities.toString(),
                    color: Colors.green,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.attach_money,
                    label: 'Budget',
                    value: '\$${totalBudget.toStringAsFixed(0)}',
                    color: Colors.orange,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryCard(Itinerary itinerary, ItineraryProvider provider, ThemeData theme) {
    final now = DateTime.now();
    final isUpcoming = itinerary.startDate.isAfter(now);
    final isPast = itinerary.endDate.isBefore(now);
    final isCurrent = !isUpcoming && !isPast;
    
    String statusLabel;
    Color statusColor;
    
    if (isCurrent) {
      statusLabel = 'In Progress';
      statusColor = Colors.green;
    } else if (isUpcoming) {
      final daysUntil = itinerary.startDate.difference(now).inDays;
      statusLabel = daysUntil == 0 ? 'Starts Today' : 'In $daysUntil days';
      statusColor = Colors.blue;
    } else {
      statusLabel = 'Completed';
      statusColor = Colors.grey;
    }

    final totalBudget = provider.calculateTotalBudget(itinerary);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.go('/itinerary/${itinerary.id}');
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                itinerary.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          itinerary.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.go('/itinerary/${itinerary.id}/edit');
                          break;
                        case 'duplicate':
                          _duplicateItinerary(itinerary.id);
                          break;
                        case 'share':
                          _shareItinerary(itinerary);
                          break;
                        case 'export':
                          _exportItinerary(itinerary);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(itinerary.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 8),
                            Text('Export PDF'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Date and Duration Info
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${Helpers.formatDate(itinerary.startDate)} - ${Helpers.formatDate(itinerary.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${itinerary.days.length} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                        ),
                      ),
                    ],
                  ),
                  if (totalBudget > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${itinerary.currency} ${totalBudget.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _calculateProgress(itinerary),
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Text(
                    '${(_calculateProgress(itinerary) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                _getProgressText(itinerary),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No Itineraries Found' 
                  : 'No Itineraries Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Create your first travel itinerary\nand start planning your adventure!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.paddingExtraLarge),
            if (_searchQuery.isEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => context.go('/itinerary/create'),
                icon: const Icon(Icons.add),
                label: const Text('Create Itinerary'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextButton.icon(
                onPressed: () => context.go('/destinations'),
                icon: const Icon(Icons.explore),
                label: const Text('Explore Destinations'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateProgress(Itinerary itinerary) {
    if (itinerary.days.isEmpty) return 0.0;
    
    int totalActivities = 0;
    int completedActivities = 0;
    
    for (final day in itinerary.days) {
      totalActivities += day.activities.length;
      completedActivities += day.activities.where((a) => a.isBooked).length;
    }
    
    return totalActivities > 0 ? completedActivities / totalActivities : 0.0;
  }

  String _getProgressText(Itinerary itinerary) {
    if (itinerary.days.isEmpty) return 'No activities planned';
    
    int totalActivities = 0;
    int completedActivities = 0;
    
    for (final day in itinerary.days) {
      totalActivities += day.activities.length;
      completedActivities += day.activities.where((a) => a.isBooked).length;
    }
    
    return '$completedActivities of $totalActivities activities completed';
  }

  void _duplicateItinerary(String itineraryId) async {
    final provider = Provider.of<ItineraryProvider>(context, listen: false);
    final itinerary = provider.getItineraryById(itineraryId);
    
    if (itinerary == null) return;
    
    // Create a copy with new dates (1 week after original)
    final newStartDate = itinerary.startDate.add(const Duration(days: 7));
    final newEndDate = itinerary.endDate.add(const Duration(days: 7));
    
    final duplicatedItinerary = Itinerary(
      id: '',
      title: '${itinerary.title} (Copy)',
      description: itinerary.description,
      startDate: newStartDate,
      endDate: newEndDate,
      days: itinerary.days.map((day) {
        return ItineraryDay(
          id: '${DateTime.now().millisecondsSinceEpoch}_${day.dayNumber}',
          dayNumber: day.dayNumber,
          date: day.date.add(const Duration(days: 7)),
          activities: day.activities.map((activity) {
            return ItineraryActivity(
              id: '${DateTime.now().millisecondsSinceEpoch}_${activity.id}',
              title: activity.title,
              description: activity.description,
              startTime: activity.startTime.add(const Duration(days: 7)),
              endTime: activity.endTime.add(const Duration(days: 7)),
              destination: activity.destination,
              type: activity.type,
              cost: activity.cost,
              currency: activity.currency,
              isBooked: false,
              notes: activity.notes,
            );
          }).toList(),
          notes: day.notes,
        );
      }).toList(),
      imageUrl: itinerary.imageUrl,
      totalBudget: itinerary.totalBudget,
      currency: itinerary.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final newId = await provider.createItinerary(duplicatedItinerary);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Itinerary duplicated successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              if (newId != null) {
                context.go('/itinerary/$newId');
              }
            },
          ),
        ),
      );
    }
  }

  void _shareItinerary(Itinerary itinerary) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Itinerary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Share via Email'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email app...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Share via Message'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening messaging app...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Generate QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code generated!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportItinerary(Itinerary itinerary) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Export Itinerary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose export format:',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF Document'),
                subtitle: const Text('Detailed itinerary with all information'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport(itinerary, 'PDF');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Excel Spreadsheet'),
                subtitle: const Text('Editable format with activities'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport(itinerary, 'Excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.blue),
                title: const Text('Calendar File'),
                subtitle: const Text('Import to your calendar app'),
                onTap: () {
                  Navigator.pop(context);
                  _performExport(itinerary, 'Calendar');
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
        );
      },
    );
  }

  void _performExport(Itinerary itinerary, String format) {
    // Simulate export process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting "${itinerary.title}" as $format...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // In a real app, this would generate the actual file
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$format exported successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // Open the exported file
              },
            ),
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(String itineraryId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Itinerary'),
        content: Text(
          'Are you sure you want to delete this itinerary? This action cannot be undone.',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final itineraryProvider = Provider.of<ItineraryProvider>(context, listen: false);
              itineraryProvider.deleteItinerary(itineraryId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Itinerary deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
