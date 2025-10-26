import 'package:flutter/foundation.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationProvider with ChangeNotifier {
  final DestinationService _destinationService = DestinationService();
  
  List<Destination> _destinations = [];
  List<Destination> _favoriteDestinations = [];
  List<Destination> _popularDestinations = [];
  List<Destination> _recommendedDestinations = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = '';
  String _searchQuery = '';

  // Getters
  List<Destination> get destinations => _destinations;
  List<Destination> get favoriteDestinations => _favoriteDestinations;
  List<Destination> get popularDestinations => _popularDestinations;
  List<Destination> get recommendedDestinations => _recommendedDestinations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => _destinationService.getCategories();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _destinationService.initialize();
      await loadDestinations();
      await loadFavoriteDestinations();
      await loadPopularDestinations();
      await loadRecommendedDestinations();
    } catch (e) {
      _errorMessage = 'Failed to initialize destinations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDestinations({String? category, String? searchQuery}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinations = await _destinationService.getDestinations(
        category: category ?? _selectedCategory,
        searchQuery: searchQuery ?? _searchQuery,
      );
    } catch (e) {
      _errorMessage = 'Failed to load destinations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteDestinations() async {
    try {
      _favoriteDestinations = await _destinationService.getFavoriteDestinations();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load favorite destinations';
      notifyListeners();
    }
  }

  Future<void> loadPopularDestinations() async {
    try {
      _popularDestinations = await _destinationService.getPopularDestinations();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load popular destinations';
      notifyListeners();
    }
  }

  Future<void> loadRecommendedDestinations() async {
    try {
      _recommendedDestinations = await _destinationService.getRecommendedDestinations();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load recommended destinations';
      notifyListeners();
    }
  }

  Future<Destination?> getDestinationById(String id) async {
    try {
      return await _destinationService.getDestinationById(id);
    } catch (e) {
      _errorMessage = 'Failed to load destination details';
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFavorite(String destinationId) async {
    try {
      final success = await _destinationService.toggleFavorite(destinationId);
      if (success) {
        // Update the destination in the current list
        final index = _destinations.indexWhere((d) => d.id == destinationId);
        if (index != -1) {
          _destinations[index] = _destinations[index].copyWith(
            isFavorite: !_destinations[index].isFavorite,
          );
        }
        
        // Reload favorites
        await loadFavoriteDestinations();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update favorite';
      notifyListeners();
    }
  }

  bool isFavorite(String destinationId) {
    return _destinationService.isFavorite(destinationId);
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      loadDestinations();
    }
  }

  void clearCategory() {
    if (_selectedCategory.isNotEmpty) {
      _selectedCategory = '';
      loadDestinations();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadDestinations();
    }
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      loadDestinations();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDestinations();
    await loadFavoriteDestinations();
    await loadPopularDestinations();
    await loadRecommendedDestinations();
  }
}