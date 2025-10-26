import 'package:flutter/foundation.dart';
import '../models/itinerary.dart';
import '../services/itinerary_service.dart';

class ItineraryProvider with ChangeNotifier {
  final ItineraryService _itineraryService = ItineraryService();
  
  List<Itinerary> _itineraries = [];
  List<Itinerary> _upcomingItineraries = [];
  List<Itinerary> _pastItineraries = [];
  List<Itinerary> _currentItineraries = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Itinerary> get itineraries => _itineraries;
  List<Itinerary> get upcomingItineraries => _upcomingItineraries;
  List<Itinerary> get pastItineraries => _pastItineraries;
  List<Itinerary> get currentItineraries => _currentItineraries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _itineraryService.initialize();
      await loadItineraries();
    } catch (e) {
      _errorMessage = 'Failed to initialize itineraries';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItineraries() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _itineraries = _itineraryService.itineraries;
      _upcomingItineraries = _itineraryService.getUpcomingItineraries();
      _pastItineraries = _itineraryService.getPastItineraries();
      _currentItineraries = _itineraryService.getCurrentItineraries();
    } catch (e) {
      _errorMessage = 'Failed to load itineraries';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createItinerary(Itinerary itinerary) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _itineraryService.createItinerary(itinerary);
      await loadItineraries();
      return id;
    } catch (e) {
      _errorMessage = 'Failed to create itinerary';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateItinerary(Itinerary itinerary) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _itineraryService.updateItinerary(itinerary);
      if (success) {
        await loadItineraries();
      } else {
        _errorMessage = 'Failed to update itinerary';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update itinerary';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItinerary(String itineraryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _itineraryService.deleteItinerary(itineraryId);
      if (success) {
        await loadItineraries();
      } else {
        _errorMessage = 'Failed to delete itinerary';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete itinerary';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Itinerary? getItineraryById(String id) {
    return _itineraryService.getItineraryById(id);
  }

  Future<bool> addActivityToDay(String itineraryId, int dayNumber, ItineraryActivity activity) async {
    try {
      final success = await _itineraryService.addActivityToDay(itineraryId, dayNumber, activity);
      if (success) {
        await loadItineraries();
      } else {
        _errorMessage = 'Failed to add activity';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to add activity';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeActivityFromDay(String itineraryId, int dayNumber, String activityId) async {
    try {
      final success = await _itineraryService.removeActivityFromDay(itineraryId, dayNumber, activityId);
      if (success) {
        await loadItineraries();
      } else {
        _errorMessage = 'Failed to remove activity';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to remove activity';
      notifyListeners();
      return false;
    }
  }

  double calculateTotalBudget(Itinerary itinerary) {
    return _itineraryService.calculateTotalBudget(itinerary);
  }

  List<Itinerary> searchItineraries(String query) {
    return _itineraryService.searchItineraries(query);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadItineraries();
  }

  // Helper method to create a basic itinerary structure
  Itinerary createBasicItinerary({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String imageUrl = '',
  }) {
    final days = <ItineraryDay>[];
    final duration = endDate.difference(startDate).inDays + 1;
    
    for (int i = 0; i < duration; i++) {
      final date = startDate.add(Duration(days: i));
      days.add(ItineraryDay(
        id: '${DateTime.now().millisecondsSinceEpoch}_day_${i + 1}',
        dayNumber: i + 1,
        date: date,
        activities: [],
      ));
    }

    return Itinerary(
      id: '', // Will be set by the service
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      days: days,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}