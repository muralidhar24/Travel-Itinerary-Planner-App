import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

class ItineraryService {
  static const String _itinerariesKey = 'user_itineraries';
  
  // Singleton pattern
  static final ItineraryService _instance = ItineraryService._internal();
  factory ItineraryService() => _instance;
  ItineraryService._internal();

  List<Itinerary> _itineraries = [];
  List<Itinerary> get itineraries => _itineraries;

  Future<void> initialize() async {
    await _loadItineraries();
  }

  Future<void> _loadItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    final itinerariesJson = prefs.getString(_itinerariesKey);
    if (itinerariesJson != null) {
      final List<dynamic> itinerariesList = jsonDecode(itinerariesJson);
      _itineraries = itinerariesList.map((json) => Itinerary.fromJson(json)).toList();
    }
  }

  Future<void> _saveItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    final itinerariesJson = jsonEncode(_itineraries.map((i) => i.toJson()).toList());
    await prefs.setString(_itinerariesKey, itinerariesJson);
  }

  Future<String> createItinerary(Itinerary itinerary) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final newItinerary = Itinerary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: itinerary.title,
        description: itinerary.description,
        startDate: itinerary.startDate,
        endDate: itinerary.endDate,
        days: itinerary.days,
        imageUrl: itinerary.imageUrl,
        totalBudget: itinerary.totalBudget,
        currency: itinerary.currency,
        isShared: itinerary.isShared,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _itineraries.add(newItinerary);
      await _saveItineraries();
      
      return newItinerary.id;
    } catch (e) {
      throw Exception('Failed to create itinerary: $e');
    }
  }

  Future<bool> updateItinerary(Itinerary updatedItinerary) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _itineraries.indexWhere((i) => i.id == updatedItinerary.id);
      if (index != -1) {
        _itineraries[index] = Itinerary(
          id: updatedItinerary.id,
          title: updatedItinerary.title,
          description: updatedItinerary.description,
          startDate: updatedItinerary.startDate,
          endDate: updatedItinerary.endDate,
          days: updatedItinerary.days,
          imageUrl: updatedItinerary.imageUrl,
          totalBudget: updatedItinerary.totalBudget,
          currency: updatedItinerary.currency,
          isShared: updatedItinerary.isShared,
          createdAt: updatedItinerary.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await _saveItineraries();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItinerary(String itineraryId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      _itineraries.removeWhere((i) => i.id == itineraryId);
      await _saveItineraries();
      return true;
    } catch (e) {
      return false;
    }
  }

  Itinerary? getItineraryById(String id) {
    try {
      return _itineraries.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Itinerary> getUpcomingItineraries() {
    final now = DateTime.now();
    return _itineraries
        .where((i) => i.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<Itinerary> getPastItineraries() {
    final now = DateTime.now();
    return _itineraries
        .where((i) => i.endDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));
  }

  List<Itinerary> getCurrentItineraries() {
    final now = DateTime.now();
    return _itineraries
        .where((i) => i.startDate.isBefore(now) && i.endDate.isAfter(now))
        .toList();
  }

  Future<bool> addActivityToDay(String itineraryId, int dayNumber, ItineraryActivity activity) async {
    try {
      final itinerary = getItineraryById(itineraryId);
      if (itinerary == null) return false;

      final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
      if (dayIndex == -1) return false;

      final updatedActivities = List<ItineraryActivity>.from(itinerary.days[dayIndex].activities);
      updatedActivities.add(activity);

      final updatedDay = ItineraryDay(
        id: itinerary.days[dayIndex].id,
        dayNumber: itinerary.days[dayIndex].dayNumber,
        date: itinerary.days[dayIndex].date,
        activities: updatedActivities,
        notes: itinerary.days[dayIndex].notes,
      );

      final updatedDays = List<ItineraryDay>.from(itinerary.days);
      updatedDays[dayIndex] = updatedDay;

      final updatedItinerary = Itinerary(
        id: itinerary.id,
        title: itinerary.title,
        description: itinerary.description,
        startDate: itinerary.startDate,
        endDate: itinerary.endDate,
        days: updatedDays,
        imageUrl: itinerary.imageUrl,
        totalBudget: itinerary.totalBudget,
        currency: itinerary.currency,
        isShared: itinerary.isShared,
        createdAt: itinerary.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateItinerary(updatedItinerary);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeActivityFromDay(String itineraryId, int dayNumber, String activityId) async {
    try {
      final itinerary = getItineraryById(itineraryId);
      if (itinerary == null) return false;

      final dayIndex = itinerary.days.indexWhere((d) => d.dayNumber == dayNumber);
      if (dayIndex == -1) return false;

      final updatedActivities = itinerary.days[dayIndex].activities
          .where((a) => a.id != activityId)
          .toList();

      final updatedDay = ItineraryDay(
        id: itinerary.days[dayIndex].id,
        dayNumber: itinerary.days[dayIndex].dayNumber,
        date: itinerary.days[dayIndex].date,
        activities: updatedActivities,
        notes: itinerary.days[dayIndex].notes,
      );

      final updatedDays = List<ItineraryDay>.from(itinerary.days);
      updatedDays[dayIndex] = updatedDay;

      final updatedItinerary = Itinerary(
        id: itinerary.id,
        title: itinerary.title,
        description: itinerary.description,
        startDate: itinerary.startDate,
        endDate: itinerary.endDate,
        days: updatedDays,
        imageUrl: itinerary.imageUrl,
        totalBudget: itinerary.totalBudget,
        currency: itinerary.currency,
        isShared: itinerary.isShared,
        createdAt: itinerary.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateItinerary(updatedItinerary);
    } catch (e) {
      return false;
    }
  }

  double calculateTotalBudget(Itinerary itinerary) {
    double total = 0.0;
    for (final day in itinerary.days) {
      for (final activity in day.activities) {
        total += activity.cost;
      }
    }
    return total;
  }

  List<Itinerary> searchItineraries(String query) {
    if (query.isEmpty) return _itineraries;
    
    return _itineraries.where((itinerary) =>
      itinerary.title.toLowerCase().contains(query.toLowerCase()) ||
      itinerary.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}