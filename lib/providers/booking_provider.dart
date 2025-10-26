import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Booking> get upcomingBookings => 
      _bookings.where((b) => b.isUpcoming).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<Booking> get activeBookings => 
      _bookings.where((b) => b.isActive).toList();

  List<Booking> get completedBookings => 
      _bookings.where((b) => b.isCompleted).toList()
        ..sort((a, b) => b.endDate.compareTo(a.endDate));

  List<Booking> get cancelledBookings => 
      _bookings.where((b) => b.isCancelled).toList();

  Future<void> initialize() async {
    await loadBookings();
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate loading bookings from a service
      // In a real app, this would fetch from an API or database
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Add some sample bookings for demonstration
      _bookings.clear();
      _bookings.addAll(_getSampleBookings());
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load bookings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(Booking booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      _bookings.add(booking);
      
      // Send notification
      await NotificationService.instance.sendBookingNotification(
        'Your booking for ${booking.destinationName} has been confirmed!',
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: 'cancelled',
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sample bookings for demonstration
  List<Booking> _getSampleBookings() {
    final now = DateTime.now();
    return [
      Booking(
        id: '1',
        userId: 'user1',
        destinationId: '1',
        destinationName: 'Bali, Indonesia',
        destinationImage: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 37)),
        numberOfPeople: 2,
        totalPrice: 2500.00,
        status: 'confirmed',
        bookingType: 'package',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Booking(
        id: '2',
        userId: 'user1',
        destinationId: '2',
        destinationName: 'Jaipur, Rajasthan',
        destinationImage: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791',
        startDate: now.add(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 65)),
        numberOfPeople: 2,
        totalPrice: 3200.00,
        status: 'confirmed',
        bookingType: 'package',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Booking(
        id: '3',
        userId: 'user1',
        destinationId: '3',
        destinationName: 'Tokyo, Japan',
        destinationImage: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.subtract(const Duration(days: 13)),
        numberOfPeople: 1,
        totalPrice: 2800.00,
        status: 'completed',
        bookingType: 'package',
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 13)),
      ),
    ];
  }
}